#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "graph.h"
#include "tree.h"

int main(){
    // Datos a rellenar
    int N = 10;
    FILE *archivo = fopen("yourdocument.tsv", "r");
    char cad[100];
    int n;
    int vertices[N];
    float latitud[N];
    float longitud[N];
    int it = 0;

    while(  it < N){
        fscanf(archivo, "%i\t%s\t%f\t%f", &vertices[it], &cad,&latitud[it],&longitud[it]);
        it++;
    }
    fclose(archivo);
    graph* g = create_graph(N,vertices);
    float r = 6371.0088;
    for(int i = 0; i < g->V; i++){
        for(int j = i+1; j < g->V; j++){
            float w = 2*r*asin(sqrt(pow(sin(((latitud[j]-latitud[i])*acos(-1)/180)/2),2)+cos(latitud[i]*acos(-1)/180)*cos(latitud[j]*acos(-1)/180)*pow(sin(((longitud[j]-longitud[i])*acos(-1)/180)/2),2)));
            insert_edge(g, new_edge(i, j, w,latitud[j],longitud[j]));
        }
    }
    // Muestra la matriz de adyacencia del grafo
    printf("\Matriz de adyacencia del grafo \n");
    for(int i=0; i < g->V; i++)
        printf("\t%i", g->vertices[i]);
    putchar('\n');
    for(int i=0; i < g->V; i++){
        printf("%i\t", g->vertices[i]);
        for(int j=0; j < g->V; j++)
            printf("%.2f\t", g->edges[i][j]);
        putchar('\n');
    }
    // Obtiene el grado de un vértice y muestra sus conexiones
    //obtenemos los vertices y guardamos el archivo y generamos el arbol
    tree mstG;
    mstG.root = 0;
    tree mstG2;
    mstG2.root = 0;
    FILE *red_princp;
    FILE *red_resp;;
    char NombreArchivo1 []= "red_principal.tsv";
    char NombreArchivo2 []= "red_respaldo.tsv";

    red_princp = fopen(NombreArchivo1,"w");      // se abre el archivo solo para lectura de los datos
    red_resp = fopen(NombreArchivo2,"w");      // se abre el archivo solo para lectura de los datos
    int in_orden[N];
    int vert_in_orden[N];
    for(int i=0; i < g->V; i++)
    {
        for(int ip = 0; ip < N; ip++){
            in_orden[ip] = ip;
            vert_in_orden[ip] = g->vertices[ip];
        }
        //ordenamos las aristas
        for(int pas = 0; pas < g->V; pas++)
        {
            for(int j=0; j < g->V-1; j++)
            {
                if( g->edges[i][j] > g->edges[i][j+1])
                {
                    float aux = g->edges[i][j];
                    g->edges[i][j] = g->edges[i][j+1];
                    g->edges[i][j+1] = aux;
                    int aux1 = vert_in_orden[j];
                    vert_in_orden[j] = vert_in_orden[j+1];
                    vert_in_orden[j+1] = aux1;
                    int aux2 = in_orden[j];
                    in_orden[j] = in_orden[j+1];
                    in_orden[j+1] = aux2;
                }
            }
        }

        if( g->edges[i][in_orden[1]] > 0)
            fprintf(red_princp,"%i\t%i\t%.2f\n",vert_in_orden[0],vert_in_orden[1],g->edges[i][in_orden[1]]);
        if( g->edges[i][in_orden[2]] > 0)
            fprintf(red_resp,"%i\t%i\t%.2f\n",vert_in_orden[0],vert_in_orden[2],g->edges[i][in_orden[2]]);
    }

    fclose(red_princp);
    fclose(red_resp);
    //creamos los arboles
    // Obtiene sus conexiones
    int *adjacents = get_adjascent_vertices(g, 1);
    int *adjacents1 = get_adjascent_vertices(g, 2);

    for(int i = 0; i < get_vertex_degree(g,1); i++){
        tree_insert(&mstG,g->vertices[adjacents[i]]);
    }
    for(int i = 0; i < get_vertex_degree(g,2); i++){
        tree_insert(&mstG2,vert_in_orden[adjacents1[i]-1]);
    }
    // Libera la memoria
    free(adjacents);
    free(adjacents1);
    FILE *ino,*preo,*posto;

    ino = fopen("inorden.tsv","w");
    inorden(mstG.root,ino);
    fprintf(ino,"\n");
    inorden(mstG2.root,ino);
    fclose(ino);
    preo = fopen("preorden.tsv","w");
    preorden(mstG.root,preo);
    fprintf(preo,"\n");
    preorden(mstG2.root,preo);
    fclose(preo);
    posto = fopen("postorden.tsv","w");
    postorden(mstG.root,posto);
    fprintf(preo,"\n");
    postorden(mstG2.root,posto);
    //cerramos el archivo
    fclose(posto);
    // Libera la memoria
    delete_graph(g);

    return 0;
}
