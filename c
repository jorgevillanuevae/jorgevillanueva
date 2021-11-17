#include <stdbool.h>
typedef struct {
    // Desde
    int u;
    // Hacia
    int v;
    // Peso
    float w;
    float longitud;
    float latitud;
} edge;

typedef struct {
    // Número de vértices
    int V;
    // Número de aristas
    int E;

    // Si es dirigido
    bool is_digraph;

    // Arreglo con los caracteres guardados
    int* vertices;

    // Matriz de adyacencia
    float** edges;
} graph;
graph* create_graph(const int n,int v[]){
    graph* g = (graph*)malloc(sizeof(graph));

    g->V = n;
    g->E = 0;
    g->is_digraph = false;

    g->vertices = (int*)malloc(sizeof(int)*g->V);

    for(int i=0; i < g->V; i++){
        g->vertices[i] = v[i];
    }

    // Espacio para el arreglo de punteros. El espacio a pedir es suficiente
    // para almacenar los punteros que necesitamos.
    g->edges = (float**)malloc(g->V * sizeof(float*));
    if(!g->edges){
        fprintf(stderr, "Error de memoria");
        free(g->vertices);
        free(g);
        return NULL;
    }

    // Inicializa la matriz
    for(int i = 0; i < g->V; i++){
        // Espacio para cada arreglo de enteros (fila
        g->edges[i] = (float*)malloc(g->V * sizeof(float));
        // Chequeo de errores
        if(!g->edges[i]){
            fprintf(stderr, "Error de memoria");
            for(i = i-1; i >= 0; i--)
            free(g->edges[i]);
            free(g->vertices);
            free(g);
            return NULL;
        }
        // Inicializa la fila en 0
        for(int j= 0; j < g->V; j++) g->edges[i][j] = 0;
    }

    return g;
}
// Crea una nueva arista. Si w == NULL, supone peso 1
edge new_edge(const int u, const int v, const float w,float lon, float lat){
    edge e;
    e.w = w;

    e.u = u;
    e.v = v;
    e.latitud = lat;
    e.longitud = lon;

    return e;
}


// Inserta una arista en el grafo no dirigido
int insert_edge(graph* g, edge e){
    g->edges[e.u][e.v] = e.w;
    if(!g->is_digraph) g->edges[e.v][e.u] = e.w;
    g->E++;

    return g->E;
}
// Obtiene el grado del vértice
int get_vertex_degree(const graph* g, const int u){
    int degree = 0;
    for(int i = 0; i < g->V; i++)
        if(g->edges[u][i] != 0)
            degree++;

    return degree;
}
// Obtiene un arreglo con los índices de vértices adyacentes
int* get_adjascent_vertices(const graph* g,
                               const int u){
    int degree = get_vertex_degree(g, u);

    int* adjacent = (int*)malloc(sizeof(int)*degree);

    // Añade solo los vértices no vacíos
    for(int i = 0, j = 0; i < g->V; i++)
        if(g->edges[u][i] != 0){
            adjacent[j] = i;
            j++;
        }

    return adjacent;
}
void delete_graph(graph* g){
    // Esta versión libera el bloque de memoria pedido en un solo malloc
    //free(g->edges[0]);

    // Libera las filas
    for(int i= 0; i < g->V; i++) free(g->edges[i]);
    free(g->edges);
    free(g->vertices);
    free(g);
}
