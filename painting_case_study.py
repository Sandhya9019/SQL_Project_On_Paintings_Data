import pandas as pd
from sqlalchemy import create_engine


conn_string='mysql://root:123456@localhost:3306/Paintings'
db= create_engine(conn_string)
conn=db.connect()

files=['artist','canvas_size','image_link','museum_hours','museum','product_size','subject','work']

for file in files:
    df=pd.read_csv(f'C:/Data analytics (Besanet)/sql_case_study_dataset/archive (1)/{file}.csv')
    df.to_sql(file,con=conn,if_exists='replace',index=False)
