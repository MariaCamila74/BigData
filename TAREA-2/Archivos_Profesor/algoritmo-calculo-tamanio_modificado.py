# -*- coding: utf-8 -*-
"""
@Institución: IU Pascual Bravo
@Docente    : Jaime E Soto U
@asignatura : ET0155 -Fundamentos de BigData
@Grupo      : G0100
@Tarea      : Tarea Unidad 2
@Módulo     : Carga aleatoria de operaciones de venta
@Periodo    : 2024-2
@Función    : Calculo de tiempo de procesamiento y tamaño de almacenamiento
"""
import time
import sys
import re
import random
import psycopg2
from   psycopg2 import Error

# Variables globales
error_con = False
# Parámetros de conexión de la Base de datos local
v_host     = "localhost"
v_port     = "5432"
v_database = "bigdata"
v_user     = "postgres"
v_password = "postgres"

#-----------------------------------------------------------------------------
# Función:  Cargar Operaciones
#-----------------------------------------------------------------------------
def cargarOperaciones(conn, cur, reg, dep, mun, prod, fec, cant):
    try:
        # Comentamos la impresión para mejorar rendimiento
        # print("Registro: ", reg, dep, mun, prod, fec, cant, end="\n") 
    
        command='''INSERT INTO tamanio (id_registro, 
                                        id_departamento, id_municipio, id_producto, 
                                        fecha, cantidad, estado) 
                     VALUES (%s,%s,%s,%s,%s,%s,%s);'''
        cur.execute(command, (reg, dep, mun, prod, fec, cant, 'V'))
        # Hacemos commit cada 1000 registros para mejorar rendimiento
        if reg % 1000 == 0:
            conn.commit()
    except (Exception, Error) as error:
        print("Error en carga de operaciones: ", error)
        sys.exit("Error: Carga Operaciones!")
    finally:
        return

# --------------------------------------------------------------------------
# Función: Obtener tamaños de almacenamiento
# --------------------------------------------------------------------------
def obtener_tamanios(cur, nombre_bd):
    # Tamaño de la base de datos en KB
    cur.execute("SELECT pg_database_size(%s)/1024;", (nombre_bd,))
    tamaño_bd_kb = cur.fetchone()[0]
    
    # Tamaño de la tabla tamanio en KB
    cur.execute("SELECT pg_total_relation_size('tamanio')/1024;")
    tamaño_tabla_kb = cur.fetchone()[0]
    
    # Porcentaje que ocupa la tabla respecto a la BD
    if tamaño_bd_kb > 0:
        porcentaje = (tamaño_tabla_kb / tamaño_bd_kb) * 100
    else:
        porcentaje = 0
    
    return tamaño_bd_kb, tamaño_tabla_kb, porcentaje

# --------------------------------------------------------------------------
# CONEXIÓN A LA BASE DE DATOS
# --------------------------------------------------------------------------
try:
    # Conexión local a la base de datos
    connection = psycopg2.connect(user= v_user, password=v_password, host= v_host,
                                  port= v_port, database= v_database)
    # Creación cursor para realizar operaciones en la basedatos
    cursor = connection.cursor()
    # Ejecución de SQL query
    cursor.execute("SELECT version();")
    # Fetch result
    record = cursor.fetchone()
    # Imprime detalles de PostgreSQL
    print("PostgreSQL Información del Servidor")
    print(connection.get_dsn_parameters(), "\n")    
    print("Python version: ",sys.version)    
    print("Estás conectado a - ", record, "\n")
    print("Base de datos:", v_database, "\n")
    # -------------------------------------------------------------------------
    # LIMPIEZA DE TABLAS
    # -------------------------------------------------------------------------
    command = '''TRUNCATE tamanio;'''
    cursor.execute(command)    
    connection.commit()    
except (Exception, Error) as error:
    print("Error: ", error)
    error_con = True
finally:
    if (error_con):            
        sys.exit("Error de conexión con servidor PostgreSQL")

# --------------------------------------------------------------------------
# Generación aleatoria de operaciones de ventas
# --------------------------------------------------------------------------
try:
    # -------------------------------------------------------------------------
    # Cantidades de registros a procesar
    # -------------------------------------------------------------------------
    cantidades_registros = [10000, 100000, 1000000, 10000000]
    
    # Resultados que vamos a recolectar
    resultados = []
    
    for registros in cantidades_registros:
        print(f"\n{'='*60}")
        print(f"PROCESANDO {registros} REGISTROS")
        print(f"{'='*60}")
        
        # Limpiar tabla antes de cada ejecución
        cursor.execute("TRUNCATE tamanio;")
        connection.commit()
        
        # ---------------------------------------------------------------------
        # TIEMPO INICIO
        # ---------------------------------------------------------------------
        tiempo_inicio = time.time()
        tiempo_inicio_procesamiento = tiempo_inicio * 1000  # Convertir a milisegundos
        
        # ---------------------------------------------------------------------
        # Carga aleatoria de registros de operaciones de venta
        # ---------------------------------------------------------------------
        for iteracion in range(1, registros + 1):
            # Mostrar progreso cada 10000 registros
            if iteracion % 10000 == 0:
                print(f"Procesando registro {iteracion} de {registros}")
                
            # Generación aleatoria de código de producto 
            id_producto = random.randint(1, 4)
            
            # Generación aleatoria de cantidad de unidades vendidas de producto
            cantidad = random.randint(1, 5000)
            
            # Generación aleatoria de fechas - Formato: DD-MM-AAAA
            dia   = str(random.randint(1, 28))
            mes   = str(random.randint(1, 12))
            dia   = "0" + dia if len(dia) == 1 else dia
            mes   = "0" + mes if len(mes) == 1 else mes
            anio  = "2023"
            fecha = dia + "-" + mes + "-" + anio

            # Selección aleatoria de un municipio
            command   = '''SELECT * FROM municipios ORDER BY RANDOM() LIMIT 1;'''
            cursor.execute(command)
            record    = cursor.fetchall()
            # Se obtienen los valores de departamento y municipio         
            id_departamento = record[0][0]
            id_municipio    = record[0][1]
            
            # Carga de operación de venta
            cargarOperaciones(connection, cursor, iteracion, id_departamento, 
                         id_municipio, id_producto, fecha, cantidad)
        
        # Aseguramos que todos los registros se han commiteado
        connection.commit()
        
        # ---------------------------------------------------------------------
        # TIEMPO FINAL
        # ---------------------------------------------------------------------
        tiempo_final = time.time()
        tiempo_final_procesamiento = tiempo_final * 1000  # Convertir a milisegundos
        tiempo_total_milisegundos = tiempo_final_procesamiento - tiempo_inicio_procesamiento
        
        # ---------------------------------------------------------------------
        # Obtener tamaños de almacenamiento
        # ---------------------------------------------------------------------
        tamaño_bd_kb, tamaño_tabla_kb, porcentaje = obtener_tamanios(cursor, v_database)
        
        # Convertir a MB si es mayor a 1024 KB
        if tamaño_bd_kb >= 1024:
            tamaño_bd_str = f"{tamaño_bd_kb/1024:.2f} MB"
        else:
            tamaño_bd_str = f"{tamaño_bd_kb:.2f} KB"
            
        # Almacenar resultados
        resultados.append({
            'registros': registros,
            'tiempo_ms': tiempo_total_milisegundos,
            'tamaño_tabla_kb': tamaño_tabla_kb,
            'tamaño_bd': tamaño_bd_str,
            'porcentaje': porcentaje
        })
        
        # Mostrar resultados de esta ejecución
        print(f"\nRESULTADOS PARA {registros} REGISTROS:")
        print(f"Tiempo de procesamiento: {tiempo_total_milisegundos:.2f} ms")
        print(f"Tamaño de la tabla 'tamanio': {tamaño_tabla_kb:.2f} KB")
        print(f"Tamaño de la BD '{v_database}': {tamaño_bd_str}")
        print(f"Porcentaje de almacenamiento: {porcentaje:.2f}%")
    
    # -------------------------------------------------------------------------
    # Mostrar tabla resumen
    # -------------------------------------------------------------------------
    print(f"\n\n{'='*100}")
    print("TABLA RESUMEN DE RESULTADOS")
    print(f"{'='*100}")
    print("| Cantidad de registros | Tiempo de procesamiento (milisegundos) | Tamaño tabla 'tamanio' (KB) | Tamaño Base de Datos 'bigdata' | Porcentaje de almacenamiento |")
    print("|-----------------------|----------------------------------------|-----------------------------|--------------------------------|-------------------------------|")
    
    for resultado in resultados:
        print(f"| {resultado['registros']:>21,} | {resultado['tiempo_ms']:>38.2f} | {resultado['tamaño_tabla_kb']:>27.2f} | {resultado['tamaño_bd']:>30} | {resultado['porcentaje']:>29.2f}% |")
    
    connection.commit()
    
except (Exception, Error) as error:
    print("Error de procesamiento de operaciones!", error)
    sys.exit("Error ->  Generación aleatoria de datos")
finally:
    if (connection):
        connection.close()
        print("\nConexión PostgreSQL cerrada")    
        
print("Fin del proceso de carga aleatoria de operaciones - LOADING")