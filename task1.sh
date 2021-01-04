#!/usr/bin/sh

# Credencial Principal
GOOGLE_APPLICATION_CREDENTIALS="/tmp/dulce-palace-300.json" 

# VARIABLES REQUERIDAS
GCLOUD_PROJECT_NAME=$(cat $GOOGLE_APPLICATION_CREDENTIALS | grep project_id | cut -d\" -f 4)
TASK1_WORKDIR=$(pwd)
GCLOUD_BIN=$(which gcloud)


# AQUI SETEAMOS LA ZONA Y EL NOMBRE DEL CLUSTER/DOCKER IMAGE
GCLOUD_ZONE="us-east1-c"
GCLOUD_CLUSTER_NAME="cluster-task1"
GCLOUD_NUM_NODES=1
DOCKER_IMAGE_NAME="img-task1"
DOCKER_IMAGE_TAG="v1"
GCLOUD_IMAGE_NAME="gcr.io/$GCLOUD_PROJECT_NAME/$DOCKER_IMAGE_NAME"
GCLOUD_IMAGE_TAG=$DOCKER_IMAGE_TAG

# LA INFORMACION DE SALIDA
output() {
  echo "Settings : "
  echo " TASK1_WORKDIR = $TASK1_WORKDIR"
  echo " GOOGLE_APPLICATION_CREDENTIALS = $GOOGLE_APPLICATION_CREDENTIALS"
  echo " GCLOUD_BIN = $GCLOUD_BIN"
  echo " GCLOUD_ZONE = $GCLOUD_ZONE"
  echo " GCLOUD_CLUSTER_NAME = $GCLOUD_CLUSTER_NAME"
  echo " GCLOUD_NUM_NODES = $GCLOUD_NUM_NODES"
  echo " GCLOUD_PROJECT_NAME = $GCLOUD_PROJECT_NAME"
  echo " DOCKER_IMAGE_NAME = $DOCKER_IMAGE_NAME"
  echo " DOCKER_IMAGE_TAG = $DOCKER_IMAGE_TAG"
  echo " GCLOUD_IMAGE_NAME = $GCLOUD_IMAGE_NAME"
  echo " GCLOUD_IMAGE_TAG = $GCLOUD_IMAGE_TAG"
}

# help
help() {
  echo "help ..."
  echo " Define variables:"
  echo " * GOOGLE_APPLICATION_CREDENTIALS = </tmp/auth.json>"
  echo " Connect to:"
  echo " * http://<EXTERNAL_IP>/"
  echo " * http://<EXTERNAL_IP>/greetings"
  echo " * http://<EXTERNAL_IP>/square/<number>"
  echo " External IP:"
  echo " - kubectl get svc"
}

# CLUSTER DE GCLOUDr
gke_gcloud() {
  echo "gke_gcloud ..."
  
  echo Y | $GCLOUD_BIN auth configure-docker

  $GCLOUD_BIN container clusters create $GCLOUD_CLUSTER_NAME --num-nodes $GCLOUD_NUM_NODES --zone $GCLOUD_ZONE
  cd $TASK1_WORKDIR/api \
	  && $GCLOUD_BIN builds submit --tag $GCLOUD_IMAGE_NAME:$GCLOUD_IMAGE_TAG \
	  && cd $TASK1_WORKDIR

  $GCLOUD_BIN container clusters get-credentials $GCLOUD_CLUSTER_NAME --zone $GCLOUD_ZONE
  sed -e "s@IMAGE_NAME@$GCLOUD_IMAGE_NAME:$GCLOUD_IMAGE_TAG@g" $TASK1_WORKDIR/api/deployment.yaml.template > $TASK1_WORKDIR/api/deployment.yaml
  $KUBECTL_BIN create -f $TASK1_WORKDIR/api/deployment.yaml 
  $KUBECTL_BIN get all
}

# check 
init() {

  test -e "$GOOGLE_APPLICATION_CREDENTIALS" || { echo "$GOOGLE_APPLICATION_CREDENTIALS" not existing;
    help
    exit 0;
  }
  test -e "$GCLOUD_BIN" || { echo gcloud is not installed;
    help
    exit 0;
  }
  test "$GCLOUD_CLUSTER_NAME" || { echo GCLOUD_CLUSTER_NAME is not defined;
    help
    exit 0;
  }

  # modules kubectl & docker-credentials-gcr
#  [ $($GCLOUD_BIN components list 2>/dev/null | grep -i -e docker-credential-gcr | sed -e '/~^|/d' | wc -l) -eq "1" ] || { echo gcloud component docker-credentials-gcr is not installed;
#    help
#    exit 0;
#  }
 # [ $($GCLOUD_BIN components list 2>/dev/null | grep -i -e kubectl | sed -e '/~^|/d' | wc -l) -eq "1" ] || { echo gcloud component kubectl is not installed;
 #   help
 #   exit 0;
 # }

  KUBECTL_BIN=$(which kubectl)
  echo "Environment ... "
  output

  # SETEAMOS LA AUTENTICACION DE LA CUENTA DE SERVICIO Y NUESTRO PROYECTO PRINCIPAL
  $GCLOUD_BIN auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
  $GCLOUD_BIN config set project $GCLOUD_PROJECT_NAME 
  echo Y | $GCLOUD_BIN services enable cloudresourcemanager.googleapis.com
  echo Y | $GCLOUD_BIN services enable cloudbuild.googleapis.com
}

# DESTRUYE LOS RECURSOS Y BORRA LA IMAGEN DEL REGISTRO
destroy() {
  init
  
  echo Y | $KUBECTL_BIN delete -f $TASK1_WORKDIR/api/deployment.yaml # deployment 
  echo Y | $GCLOUD_BIN container clusters delete $GCLOUD_CLUSTER_NAME --zone $GCLOUD_ZONE # cluster
  echo Y | $GCLOUD_BIN container images delete $GCLOUD_IMAGE_NAME:$GCLOUD_IMAGE_TAG # gcloud image
}

# CREANDO CLUSTER
create() {
  init
  gke_gcloud # with gcloud
}

case "$1" in
  "destroy" ) echo "call destroy ..." && destroy
	  ;;
  "create" ) echo "call create ..." && create
	  ;;
  "output" ) echo "call output ..." && output
	  ;;
  *) echo "exit" && help 
esac
