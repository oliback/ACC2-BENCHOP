echo "Creating and initiating instance...."

nova boot --flavor 8e704ef9-74dc-495e-9e2b-baebc6775b16 --key-name acc-2-key --image 9fea0ce0-e500-4ed3-af74-7da48d24895e --user-data instance.yml --nic net-id=7d1c469d-48ce-463d-8173-f3efbf8cb900 --config-drive true acc-2-BENCHOP-2
