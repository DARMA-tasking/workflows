# Local build and test vt sample
# To be removed once CI works correctly
# docker run 61e79ce38e1e /bin/bash -c "$(cat ./ci/test-samples/build-and-test-vt.sh)"

mkdir -p /opt/vt/src
git clone https://github.com/DARMA-tasking/vt /opt/vt/src

mkdir -p /opt/vt/build

cd /opt/vt/src
bash ci/build_cpp.sh /opt/vt/src /opt/vt/build
bash ci/test_cpp.sh /opt/vt/src /opt/vt/build

rm -rf /opt/vt/src /opt/vt/build