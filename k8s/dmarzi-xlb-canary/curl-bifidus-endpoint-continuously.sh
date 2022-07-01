#!/bin/bash

function _curl() {
    curl "$@" 2>/dev/null
}
DEFAULT_NUMBER_OF_TESTS="20"
N_TESTS=${1:-$DEFAULT_NUMBER_OF_TESTS}
echo 'This should prove endpoint2 is used 9x more than endpoint1: Ill use microsleep provided by palladius/sakura'

rm -f .tmpfile

for N in $(seq $N_TESTS); do
    echo -n "TEST[$N]:"
    _curl http://store-bifido.palladius.it/ | egrep "metadata" | tee -a .tmpfile
    # sleep 50ms
    #usleep 50000
done

echo 'Results on request skewness (how many requests go to endpoint 1 vs 2):'
cat .tmpfile | awk '{print $2}' | sort | uniq -c  
