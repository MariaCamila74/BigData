import random
import json
from datetime import datetime, timedelta
import pandas as pd
import psycopg2

# ----------------------------------------
# CONFIGURACIÓN DE RANGOS DE DATOS
# ----------------------------------------
def generar_lectura(sensor_id, mc_id, linea_id, fabrica_id, turno_id, nivel_id, fecha_base):
    # Valores aleatorios simulando condiciones reales
    concentracion = round(random.uniform(0.10, 450.0), 3)
    temperatura = round(random.uniform(20.0, 40.0), 2)
    humedad = round(random.uniform(40.0, 80.0), 2)
    presion = round(random.uniform(990.0, 1020.0), 2)

    # Coordenadas reales aproximadas (ejemplo Medellín)
    lat = round(random.uniform(6.20, 6.35), 6)
    lon = round(random.uniform(-75.60, -75.55), 6)

    # Tiempo de la lectura
    fecha_hora = fecha_base

    # Campo JSONB con información adicional
    payload = {
        "sensor_status": "OK",
        "battery": random.randint(60, 100),
        "signal_strength": random.randint(50, 100)
    }

    return {
        "id_sensor": sensor_id,
        "id_mc": mc_id,
        "id_linea": linea_id,
        "id_fabrica": fabrica_id,
        "id_turno": turno_id,
        "id_nivel": nivel_id,
        "fecha_hora": fecha_hora,
        "concentracion_ppm": concentracion,
        "temperatura": temperatura,
        "humedad": humedad,
        "presion_atmosferica": presion,
        "latitud": lat,
        "longitud": lon,
        "geom": f"POINT({lon} {lat})",
        "payload": json.dumps(payload)
    }


# ----------------------------------------------------
# GENERAR 1000 REGISTROS PARA LA TABLA “LECTURAS”
# ----------------------------------------------------
def generar_registros_tabla():
    fecha = datetime.now()

    registros = []
    for i in range(1000):
        registro = generar_lectura(
            sensor_id=random.randint(1, 240),
            linea_id=random.randint(1, 12),
            mc_id=random.randint(1, 240),
            fabrica_id=random.randint(10, 12),
            turno_id=random.randint(10, 12),
            nivel_id=random.randint(1, 4),
            fecha_base=fecha + timedelta(seconds=i)
        )
        registros.append(registro)

    return registros


# ----------------------------------------------------
# GUARDAR EN CSV PARA “lecturas-sensor”
# ----------------------------------------------------
def generar_excel_sensor(registros):
    df = pd.DataFrame(registros)
    df = df.drop(columns=["geom", "payload"])  # El microcontrolador no usa estos campos
    df.to_excel("lecturas-sensor.xlsx", index=False)
    print("✔ Hoja lecturas-sensor.xlsx generada correctamente.")


# ----------------------------------------------------
# INSERCIÓN EN BASE DE DATOS POSTGRESQL
# ----------------------------------------------------
def insertar_en_postgres(registros):
    conn = psycopg2.connect(
        dbname="monitoreo-produccion",
        user="postgres",
        password="12345",
        host="localhost",
        port="5433"
    )
    cursor = conn.cursor()

    query = """
    INSERT INTO lecturas(
        id_sensor, id_mc, id_linea, id_fabrica, id_turno, id_nivel,
        fecha_hora, concentracion_ppm, temperatura, humedad,
        presion_atmosferica, latitud, longitud, geom, payload
    ) VALUES (
        %(id_sensor)s, %(id_mc)s, %(id_linea)s, %(id_fabrica)s, %(id_turno)s, %(id_nivel)s,
        %(fecha_hora)s, %(concentracion_ppm)s, %(temperatura)s, %(humedad)s,
        %(presion_atmosferica)s, %(latitud)s, %(longitud)s,
        ST_GeomFromText(%(geom)s, 4326), %(payload)s::jsonb
    );
    """

    for r in registros:
        cursor.execute(query, r)

    conn.commit()
    cursor.close()
    conn.close()
    print("✔ Registros insertados en PostgreSQL correctamente.")


# ----------------------------------------------------
# PROGRAMA PRINCIPAL
# ----------------------------------------------------
if __name__ == "__main__":
    registros = generar_registros_tabla()
    generar_excel_sensor(registros)
    insertar_en_postgres(registros)