# Test with local built image (using the workflows built image not the vt one. That should be tested in a second phase)
# test with local built image: docker run 3506b1369c84 /bin/bash -c "$(cat ./ci/test-samples/build-and-test-vt.sh)"

echo "mpicc=$(which mpicc)"
echo "mpicxx=$(which mpicxx)"
echo "mpich=$(which mpich)"

ls /usr/bin -l


export MPI_C=mpicc
export MPI_CXX=mpicxx

# mkdir -p /opt/vt/src
# git clone https://github.com/DARMA-tasking/vt /opt/vt/src



# mkdir -p /opt/vt/build
# cd /opt/vt/src
# bash ci/build_cpp.sh /opt/vt/src /opt/vt/build
# bash ci/test_cpp.sh /opt/vt/src /opt/vt/build

rm -rf /opt/vt/src /opt/vt/build