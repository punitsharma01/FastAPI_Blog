import psycopg

host = "xxxx.us-west-1.rds.amazonaws.com"
user = ""
password = ""
dbname = ""
conn = None
try:
    conn = psycopg.connect(
        host=host,
        dbname=dbname,
        user=user,
        password=password,
        port=5432,
        connect_timeout=5
    )

    cur = conn.cursor()
    cur.execute("SELECT version();")
    print("If you see Version, means db is connected")
    print(cur.fetchone())
except Exception as e:
    print(f"Database error: {e}")
    raise
finally:
    if conn:
        conn.close()
