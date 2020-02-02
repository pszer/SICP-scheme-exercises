// Abstract : Electrical circuit simulator for DC circuits.
//
// Model is made up of three objects: components, nodes and wires.
// - Components are a collection of nodes and some function that updates
// the voltages/current on those nodes.
// - Nodes are generic objects that have some voltage and current. They
// are owned by their parent components and are 'read' by components for their
// voltage and current.
// - Wires are objects that hold value and can be connected to two nodes.
//
// There are two methods of simulating the circuit.
// - Update cycles : Every iteration :
//   * Each component has its update function called during which it reads
//      in it's input nodes and changes the value of it's
//      output node.
//   * After each component is updated, each wire is updated during which
//      it reads the output node it's connected to, the wire updates it's value
//      then sets the value of the input node it's connected to.
// - This method has a drawback in the fact it doesn't mimic the way actual
//    electricity propagates through a circuit, and this is seen in the fact that
//    nodes have to be differentiated as either input or output nodes which is
//    not a real phenomenon. Nodes will be set to be either input or output nodes
//    on creation, or will have their parity decided by traversing the circuit
//    from an electricity source to determine the flow of current, which is too
//    costly (because the flow of current could be designed to change in a circuit,
//    so the flow would have to be calculated every iteration) and complicated.
//
// - Propagation : Every iteration :
//   * Set the value of all nodes to 0V 0C.
//   * Find an electricity source component as the root of electricity propogation.
//   * Call it's update function which does only one thing :
//     @ Updates the voltage/current of the sources single node to whatever the sources
//       power is, and call the nodes update function, telling it that it was a
//       component that called it.
//   * All nodes have an update function which is is (with a 'which thing called
//      me' parameter) :
//     @ If a component called it, update the wire the node is connected to.
//     @ If a wire called it, update the component the node is connected to.
//   * All wires have a wire update function which is (with a 'which node called me' parameter):
//     @ Update the voltage/current of the wire from the power of the node which called it.
//     @ Add to the voltage/current of the node which didn't call it the value of the wire
//       and call the node's update function, telling it that a wire called it.
//   * Calling the source component will propagate an update signal throughout the whole
//     circuit it's connected to.
//   * If there are multiple electricity sources, do an update for each of them.
// - This method is better than the update cycle method, there is no need to
//    differentiate between which nodes are input or output nodes, as the propagation
//    of the update calls simulates the current flow. It would be possible to create
//    a circuit that causes the propagation of update calls to loop forever with the proper
//    components, but this can be circumvented as follows :
//   * At the beginning of the iteration mark all wires as unvisited.
//   * Whenever a wire is updated, mark it as visited.
//   * If a wire is called to update and it's already visited, ignore the call.
// - Another problem is that this process has recursive elements, in the sense that
//    the initial update call on the source causes update calls on the other components
//    and those calls call update calls on other components and so on, in a big enough circuit
//    this could cause a stack overflow as each update call creates a stack frame which isn't
//    deleted until the end of the propagation. This can be circumvented by implementing
//    a self-made stack for update calls on the heap which would be huuuuge enough
//    for any circuit, but this would only be needed for truly massive circuits.
//
// This simulator will use the propagation model.
//
// <node> <comp> <wire> are all mutable
// <marked> ⊆ <wires>
// <node> is pair (voltage,current) voltage,current ∈ real
// <comp> is 2-tuple (N,δ) N = set of nodes ; λδ.<node>(...)
// <wire> is 4-tuple (voltage,current,n1,n2) n1,n2 ∈ <nodes> voltage,current ∈ real
// (λUN.<node>)(λx.(if (x∈<wires>)
//                     (<parent-node>δ(<node>))
//                     ({w|<node>∈w}(UW(w,<node>)))))
// (λUW.<wire>)(when ¬(w∈<marked>) (
//                λ<node> (set! voltage,current (voltage <node>)
//                                              (/ (current <node>) |{w|<node>∈w}|))
//                        (+=set! (voltage,current <other-node>) voltage,current)
//                        (insert! <marked> <wire>)
//                        (U(<other-node>))))
//
// definition of propagate.
// @ time=0
// <marked>=0, ∀n∈<nodes>[n=(0,0)]
// λpropogate = sourceδ(NULL)
//
// assume ∀δ[δ∈TIME(O(n))]
// evaluating all calls of ¬∃w[w∈<marked>] ∈ TIME(O(n)) if constant lookup O(1)
//                         ¬∃w[w∈<marked>] ∈ TIME(O(n^2)) if constant lookup O(n)
// worst-case evaluating λ<node> is t(λ<node>)*(|<nodes>+<wires>|) ∈ O(n)*O(1) = TIME(O(n))
// -> propogate ∈ O(n) if constant <marked> lookup
//    propogate ∈ O(n^2) if linear <marked> lookup

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

// ignore this
typedef struct component component;
typedef struct node node;
typedef struct wire wire;
//

#define MAX_NODE_CONNECTIONS 8
#define MAX_COMP_NODES 8
#define MAX_VISITED_WIRES 128

enum { CALLED_BY_WIRE , CALLED_BY_COMPONENT };

// Data structures.
// - Node
//   * Has an electricity value and pointers to which
//      wires it's connected to.
//   * Max 8 wires connected to a node for simplicity.
//   * Has a pointer to it's parent component.
struct node {
	// electricity value
	double voltage, current;

	// memory pointers to which wires the node is
	// connected to (set to NULL if not connected)
	int connections;
	wire * connection[MAX_NODE_CONNECTIONS];

	component * parent;
};

// Creates a node
node CreateNode(component * parent);

// Updates a node, the 'what_called_me' argument is either
// CALLED_BY_WIRE or CALLED_BY_COMPONENT.
void UpdateNode(node * n, int what_called_me);

// Adds a connection to a node.
void NodeAddConnection(node * n, wire * w);

// - Wire
//   * Has an electricity value and two pointers to
//     each node it's connected to.
struct wire {
	double voltage, current;

	node * connect_a, * connect_b;
};

// Creates a wire connected to two nodes.
wire CreateWire(node * a, node * b);

// Updates a wire. Should only be called by a node, and it should
// give a pointer to itself as the 'which_node_called_me' argument.
void UpdateWire(wire * w, node * which_node_called_me);

// - Component
//   * Has some nodes.
//   * Has a function that is called whenever one of it's nodes is updated.
// - In this simulator, the function is a function pointer, and
//    each component will have 8 nodes, but it will specify how many it actually uses
//    as a number 'node_count'.
struct component {
	void (*function)(component *, node *); // a void function that takes in as a parameter
	                                       // itself and which node called it
										   
	node nodes[MAX_COMP_NODES]; // the components nodes
	int node_count; // how many nodes the component uses

	double data1; // a generic double to be used by the component in operation
	double data2; // a generic double to be used by the component in operation
};

// The update functions for several components
void Component_SourceUpdate(component * comp, node * which_node_called_me);
void Component_SinkUpdate(component * comp, node * which_node_called_me);
void Component_ResistorUpdate(component * comp, node * which_node_called_me);
void Component_VoltmeterUpdate(component * comp, node * which_node_called_me);

// Macros for creating different components using CreateComponent(), e.g.
// Calling CreateComponent(COMP_SOURCE) expands to CreateComponent(Component_SourceUpdate, 1)
//    component name |   component function   | component node count
#define COMP_SOURCE    Component_SourceUpdate       , 1
#define COMP_SINK      Component_SinkUpdate         , 1
#define COMP_RESISTOR  Component_ResistorUpdate     , 2
#define COMP_VOLTMETER Component_VoltmeterUpdate    , 2

// Creates a component
component CreateComponent(void (*function)(component *, node *), int node_count);

// Connects node index 'a_which_node' in a to node index 'b_which_node' in b using a given wire.
void ConnectComponent(wire * wire, component * a, int a_which_node, component * b, int b_which_node);

// Sets the 'parent' pointer of all the nodes in a component to that component.
void ComponentUpdateNodeParent(component * comp);

// Updates a component, which calls the function inside of a components.
// Should only be called by a node, which should give a pointer to itself
// as the 'which_node_called_me' argument, but can be called directly
// on primitive components such as a source with 'which_node_called_me' = NULL.
void UpdateComponent(component * comp, node * which_node_called_me);

// Sets the voltage and current of all nodes in a component to 0V/0A.
void NullComponentNodes(component * comp);

// When propagating through a circuit, wires that have been updated ("visited") are
// recorded in the 'visited_wires' stack. Wires that have already been updated
// in an iteration will not be updated again to stop cycles from happening 
// which will crash the program.
//
// NOTE: ResetVisitedWires() should be called EVERY time a propagation happens, which means
// it's called once for every source in a circuit in a full iteration. This is so that if
// there are multiple sources feeding into the same circuit a propagation from once source
// doesn't prematurely end the propagation from another source because it marked all the
// wires as visited.
wire * visited_wires[MAX_VISITED_WIRES];
int visited_wires_count = 0;

void ResetVisitedWires();       // Reset
void PushVisitedWire(wire * w); // Mark a wire as visited
int HasBeenVisited(wire * w);   // Returns 1/0 for whether or not a wire has been visited

// Does a propagation from a given source, updating the circuit.
void UpdateCircuit(component * source);

int main(int argc, char ** argv) {
	//     Creating a simple circuit
	//
	// Source 5V    Resist 25.0Ω      Sink
	//    ]|-----------^v^v------------|
	//            |           |
	//            |           |
	//            ------[V]----
	//               Voltmeter

	// the components that will be used.
	component source = CreateComponent(COMP_SOURCE);
	component resist = CreateComponent(COMP_RESISTOR);
	component sink   = CreateComponent(COMP_SINK);
	component volt_m = CreateComponent(COMP_VOLTMETER);

	// making sure nodes have their correct parents known.
	ComponentUpdateNodeParent(&source);
	ComponentUpdateNodeParent(&resist);
	ComponentUpdateNodeParent(&sink);
	ComponentUpdateNodeParent(&volt_m);

	// make source 5V 0.1A
	source.data1 = 5.0;
	source.data2 = 0.1;

	// make resistor 25 Ω
	resist.data1 = 25.0;

	// the four wires that will be used
	wire a, b, c, d;

	// connecting source -> resistor -> sink
	ConnectComponent(&a, &source, 0, &resist, 0);
	ConnectComponent(&b, &resist, 1, &sink, 0);

	// connecting voltmeter to resistor in parallel
	ConnectComponent(&c, &resist, 0, &volt_m, 0);
	ConnectComponent(&d, &resist, 1, &volt_m, 1);

	// do 5 iterations
	int i;
	for (i = 0; i < 5; ++i) {
		// normally you would keep all components in an array
		// and iterate through them to reset their nodes, but this
		// is just a demonstration.
		NullComponentNodes(&source);
		NullComponentNodes(&resist);
		NullComponentNodes(&sink);
		NullComponentNodes(&volt_m);

		// update circuit!
		UpdateCircuit(&source);
	}

	// this prints out 2.5V
	printf("voltmeter reading : %f\n", volt_m.data1);

	return 0;
}

// Updates circuit.
void UpdateCircuit(component * source) {
	ResetVisitedWires();
	UpdateComponent(source, NULL);
	ResetVisitedWires();
}

// Calls the inner function of a component so it does it's job.
void UpdateComponent(component * comp, node * which_node_called_me) {
	comp->function(comp, which_node_called_me);
}

// Sets the voltage/current of all the components nodes.
void NullComponentNodes(component * comp) {
	size_t i;
	for (i = 0; i < comp->node_count; ++i) {
		comp->nodes[i].voltage = 0.0;
		comp->nodes[i].current = 0.0;
	}
}

// Sets the sources node to the voltage and current to the sources power output
// defined in data1 and data2. Then updates the node.
void Component_SourceUpdate(component * comp, node * which_node_called_me) {
	comp->nodes[0].voltage = comp->data1;
	comp->nodes[0].current = comp->data2;

	UpdateNode(comp->nodes + 0, CALLED_BY_COMPONENT);
}

// A sink does nothing.
void Component_SinkUpdate(component * comp, node * which_node_called_me) {
	// do nothing!
}

// When the node of one end of a resistor is updated, the resistor updates
// the other end of the resistor with the right value.
// The resistance of the resistor is defined in data1.
// (The science behind this is probably wrong).
// It then updates both node ends of the resistor (it updates both instead of
// just the other end so that if anything is connected in parallel to the resistor
// the voltage difference is correct).
void Component_ResistorUpdate(component * comp, node * which_node_called_me) {
	double resistance = comp->data1;

	// checks whether node 0 was updated or node 1
	if (which_node_called_me == comp->nodes + 0)	{
		double in_voltage = comp->nodes[0].voltage;
		double in_current = comp->nodes[0].current;

		comp->nodes[1].voltage = in_current * resistance;
		comp->nodes[1].current = in_current;
	} else {
		double in_voltage = comp->nodes[1].voltage;
		double in_current = comp->nodes[1].current;

		comp->nodes[0].voltage = in_current * resistance;
		comp->nodes[0].current = in_current;
	}

	UpdateNode(comp->nodes + 0, CALLED_BY_COMPONENT);
	UpdateNode(comp->nodes + 1, CALLED_BY_COMPONENT);
}

// The voltmeter just updates the voltage difference it measures in data1 and nothing
// else.
void Component_VoltmeterUpdate(component * comp, node * which_node_called_me) {
	comp->data1 = comp->nodes[0].voltage - comp->nodes[1].voltage;
}

// Creates a node with default parameters and a parent
node CreateNode(component * parent) {
	node n;
	n.voltage = 0.0;
	n.current = 0.0;
	n.connections = 0;
	n.parent = parent;
	return n;
}

// Updates a node
// If the update call was done by a wire, update the nodes component.
// If the update call was done by a component, update the nodes wires.
void UpdateNode(node * n, int what_called_me) {
	if (what_called_me == CALLED_BY_WIRE) {
		UpdateComponent(n->parent, n);
	} else {
		size_t i;
		for (i = 0; i < n->connections; ++i) {
			UpdateWire(n->connection[i], n);
		}
	}
}

// Adds a wire connection to a node.
void NodeAddConnection(node * n, wire * w) {
	n->connection[n->connections] = w;
	n->connections++;
}

// Creates a wire connected to two given nodes.
wire CreateWire(node * a, node * b) {
	wire w;
	w.voltage = 0.0;
	w.current = 0.0;
	w.connect_a = a;
	w.connect_b = b;
	return w;
}

// Updates a wire.
// It first updates the voltage/current of itself from the node which called it,
// dividing the current by how many connections the node which called it has.
// It then updates the voltage/current of the opposite node end of the wire by adding
// the wires voltage/current to the node, then updates that node (it adds it instead
// of setting it so that if multiple wires are feeding into the same node then the
// voltage and current accumulate).
void UpdateWire(wire * w, node * which_node_called_me) {
	if (HasBeenVisited(w))
		return;
	PushVisitedWire(w);

	// divide current by how many connections the node has
	w->current = which_node_called_me->current / which_node_called_me->connections;
	w->voltage = which_node_called_me->voltage;

	if (which_node_called_me == w->connect_a) {
		w->connect_b->voltage += w->voltage;
		w->connect_b->current += w->current;
		UpdateNode(w->connect_b, CALLED_BY_WIRE);
	} else if (which_node_called_me == w->connect_b) {
		w->connect_a->voltage += w->voltage;
		w->connect_a->current += w->current;
		UpdateNode(w->connect_a, CALLED_BY_WIRE);
	}
}

// Takes a given wire and two nodes and connects them.
void ConnectComponent(wire * wire, component * a, int a_which_node, component * b, int b_which_node) {
	node * node_a = a->nodes + a_which_node;
	node * node_b = b->nodes + b_which_node;

	*wire = CreateWire(node_a, node_b);
	NodeAddConnection(node_a, wire);
	NodeAddConnection(node_b, wire);
}

// Creates a component with default parameters, a function, and node_count;
component CreateComponent(void (*function)(component *, node *), int node_count) {
	component c;
	c.function = function;
	c.node_count = node_count;
	c.data1 = 0.0;
	c.data2 = 0.0;
	return c;
}

// Makes sure the nodes of a component have the right parent pointer.
// (This is only here because in the demonstration I allocate everything
// on the stack so some pointers get invalidated but if components where
// to be created on the heap then the node's parent can be set during
// the components creation which would cause no problems).
void ComponentUpdateNodeParent(component * comp) {
	size_t i;
	for (i = 0; i < comp->node_count; ++i)
		comp->nodes[i] = CreateNode(comp);
}

// 'nuff said.
void ResetVisitedWires() {
	visited_wires_count = 0;
}

// Marks a given wire as visited.
void PushVisitedWire(wire * w) {
	visited_wires[visited_wires_count] = w;
	++visited_wires_count;
}

// Checks if a wire has been visited before or not, returning 1/0 respectively.
int HasBeenVisited(wire * w) {
	size_t i;
	for (i = 0; i < visited_wires_count; ++i)
		if (w == visited_wires[i]) return 1;
	return 0;
}
