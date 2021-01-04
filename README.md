# TASK1

# Pre-requisitos del S.O

  - Google SDK
  - Componentes ( docker-credentials-gcr, kubectl)
  - Activar los siguientes API en GCP ( Compute Engine , Kubernetes Engine ) 

# Primero, necesitamos crear una cuenta de servicio, la cual tenga el rol asignado para crear el cluster, esto es la base
  de nuestra autenticacion, se declara en el siguiente valor

    GOOGLE_APPLICATION_CREDENTIALS="/tmp/" 
    
# Parametros

    sh TASK1.sh output     =>  nos brinda informacion relevante
    sh TASK1.sh create     =>  crea los recursos necesarios para el cluster, sube la imagen al registry y despliega nuestra app
    sh TASK1.sh destroy    =>  purga todos los recursos creados 
    
# Usando la app

    http://<IP>                 => Hola Mundo :) 
    http://<IP>/greetings       => Hola Mundo + el hostname
    http://<IP>/square/<N>      => Reemplazar 'N' por un numero, este sera elevado al cuadrado
  
