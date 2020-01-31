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
//     @ Updates the value of the sources single node to whatever the sources
//       power is, and call the nodes update function, telling it that it was a
//       component that called it.
//   * All nodes are the same and a nodes update function is (with a 'which thing called
//      me' parameter) :
//     @ If a component called it, update the wire the node is connected to.
//     @ If a wire called it, update the component the wire is connected to.
//   * All wires are the same and a wires update function
//      is (with a 'which node called it' parameter):
//     @ Update the value of the wire from the value of the node which called it.
//     @ Update the value of the node which didn't call it to be the value of the wire
//       and call its update function, telling it that a wire called it.
//   * Calling the source component will propagate an update signal throughout the whole
//     circuit it's connected to.
//   * If there are multiple electricity sources, do an update for each of them.
// - This method is better than the update cycle method, there is no need to
//    differentiate between which nodes are input or output nodes, as the propagation
//    of the update calls simulates the current flow. It could be possible to create
//    a circuit that causes the propagation of update calls to loop forever, but this
//    can be circumvented as follows
//   * At the beginning of the iteration mark all wires as unvisited.
//   * Whenever a wire is updated, mark it as visited.
//   * If a wire is called to update and it's already visited, ignore the call.
// - Another problem is that this process has recursive elements, in the sense that
//    the initial update call on the source causes update calls on the other components
//    and those calls call update calls on other components and so on, in a huge enough circuit
//    this could cause a stack overflow as each update call creates a stack frame which isn't
//    deleted until the end of the propagation. This can be circumvented by implementing
//    a self-made stack for update calls on the heap which would be huuuuge enough
//    for any circuit, but this would only be needed for truely big circuits.
//
// This simulator will use the propagation model.

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

// Data structures.
// - Node
//   * Has an electricity value and pointers to which
//      wires it's pointed to.
//   * Max 8 wires connected to a node for simplicity.
//   * Has a pointer to parent component.
struct node {
	// electricity value
	double voltage, current;

	// memory pointers to which wires the node is
	// connected to (set to NULL if not connected)
	int connections;
	wire * connection[MAX_NODE_CONNECTIONS];

	component * parent;
};

enum { CALLED_BY_WIRE , CALLED_BY_COMPONENT };

node CreateNode(component * parent);
void UpdateNode(node * n, int what_called_me);
void NodeAddConnection(node * n, wire * w);

// - Wire
//   * Has an electricity value and two pointers to
//     each node it's connected to.
struct wire {
	double voltage, current;

	node * connect_a, * connect_b;
};

wire CreateWire(node * a, node * b);
void UpdateWire(wire * w, node * which_node_called_me);

// - Component
//   * Has a function that is called whenever one of it's nodes is updated.
//   * A fixed number of nodes.
// - In this simulator, the function is a void function pointer, and
//    each component will have 8 nodes, but it will specify how many it actually uses
//    as a number.
struct component {
	void (*function)(component *, node *); // a void function that takes in as parameter which node called it
	node nodes[MAX_COMP_NODES]; // the components nodes
	int node_count; // how many nodes the component actually uses

	double data1; // a generic double to be used by the component in operation
	double data2; // a generic double to be used by the component in operation
};

void Component_SourceUpdate(component * comp, node * which_node_called_me);
void Component_SinkUpdate(component * comp, node * which_node_called_me);
void Component_ResistorUpdate(component * comp, node * which_node_called_me);
void Component_VoltmeterUpdate(component * comp, node * which_node_called_me);

#define COMP_SOURCE    Component_SourceUpdate, 1
#define COMP_SINK      Component_SinkUpdate, 1
#define COMP_RESISTOR  Component_ResistorUpdate, 2
#define COMP_VOLTMETER Component_VoltmeterUpdate, 2

component CreateComponent(void (*function)(component *, node *), int node_count);

// connects node number 'a_which_node' in a to node number 'b_which_node' in b
void ConnectComponent(wire * wire, component * a, int a_which_node, component * b, int b_which_node);
void ComponentUpdateNodeParent(component * comp);
void UpdateComponent(component * comp, node * which_node_called_me);
void NullComponentNodes(component * comp);

wire * visited_wires[MAX_VISITED_WIRES];
int visited_wires_count = 0;
void ResetVisitedWires();
void PushVisitedWire(wire * w);
int HasBeenVisited(wire * w);

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

	component source = CreateComponent(COMP_SOURCE);
	component resist = CreateComponent(COMP_RESISTOR);
	component sink   = CreateComponent(COMP_SINK);
	component volt_m = CreateComponent(COMP_VOLTMETER);

	ComponentUpdateNodeParent(&source);
	ComponentUpdateNodeParent(&resist);
	ComponentUpdateNodeParent(&sink);
	ComponentUpdateNodeParent(&volt_m);

	// make source 5V 0.1A
	source.data1 = 5.0;
	source.data2 = 0.1;

	// make resistor 25 Ω
	resist.data1 = 25.0;

	wire a, b, c, d;

	// wire source -> resistor -> sink
	ConnectComponent(&a, &source, 0, &resist, 0);
	ConnectComponent(&b, &resist, 1, &sink, 0);

	// wire voltmeter to resistor in parallel
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

	printf("voltmeter reading : %f\n", volt_m.data1);

	return 0;
}

void UpdateCircuit(component * source) {
	ResetVisitedWires();
	UpdateComponent(source, NULL);
	ResetVisitedWires();
}

void UpdateComponent(component * comp, node * which_node_called_me) {
	comp->function(comp, which_node_called_me);
}

void NullComponentNodes(component * comp) {
	size_t i;
	for (i = 0; i < comp->node_count; ++i) {
		comp->nodes[i].voltage = 0.0;
		comp->nodes[i].current = 0.0;
	}
}

void Component_SourceUpdate(component * comp, node * which_node_called_me) {
	comp->nodes[0].voltage = comp->data1;
	comp->nodes[0].current = comp->data2;

	UpdateNode(comp->nodes + 0, CALLED_BY_COMPONENT);
}

void Component_SinkUpdate(component * comp, node * which_node_called_me) {
	// do nothing!
}

void Component_ResistorUpdate(component * comp, node * which_node_called_me) {
	double resistance = comp->data1;

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

void Component_VoltmeterUpdate(component * comp, node * which_node_called_me) {
	comp->data1 = comp->nodes[0].voltage - comp->nodes[1].voltage;
}

node CreateNode(component * parent) {
	node n;
	n.voltage = 0.0;
	n.current = 0.0;
	n.connections = 0;
	n.parent = parent;
	return n;
}

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

void NodeAddConnection(node * n, wire * w) {
	n->connection[n->connections] = w;
	n->connections++;
}

wire CreateWire(node * a, node * b) {
	wire w;
	w.voltage = 0.0;
	w.current = 0.0;
	w.connect_a = a;
	w.connect_b = b;
	return w;
}

void UpdateWire(wire * w, node * which_node_called_me) {
	if (HasBeenVisited(w))
		return;
	PushVisitedWire(w);

	w->voltage = which_node_called_me->voltage;
	w->current = which_node_called_me->current / which_node_called_me->connections;

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

void ConnectComponent(wire * wire, component * a, int a_which_node, component * b, int b_which_node) {
	node * node_a = a->nodes + a_which_node;
	node * node_b = b->nodes + b_which_node;

	*wire = CreateWire(node_a, node_b);
	NodeAddConnection(node_a, wire);
	NodeAddConnection(node_b, wire);
}

component CreateComponent(void (*function)(component *, node *), int node_count) {
	component c;
	c.function = function;
	c.node_count = node_count;
	c.data1 = 0.0;
	c.data2 = 0.0;
	return c;
}

void ComponentUpdateNodeParent(component * comp) {
	size_t i;
	for (i = 0; i < comp->node_count; ++i) {
		comp->nodes[i] = CreateNode(comp);
	}
}

void ResetVisitedWires() {
	visited_wires_count = 0;
}

void PushVisitedWire(wire * w) {
	visited_wires[visited_wires_count] = w;
	++visited_wires_count;
}

int HasBeenVisited(wire * w) {
	size_t i;
	for (i = 0; i < visited_wires_count; ++i)
		if (w == visited_wires[i]) return 1;
	return 0;
}
