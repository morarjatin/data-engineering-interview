k8s_yaml([
    './k8s/postgres.yaml',
    './k8s/pgadmin.yaml'
])

k8s_resource(
    'db',
    objects=["db-pvc"],
    port_forwards=['5432:5432', '5050:80'],
    links=['http://localhost:5050/']
)