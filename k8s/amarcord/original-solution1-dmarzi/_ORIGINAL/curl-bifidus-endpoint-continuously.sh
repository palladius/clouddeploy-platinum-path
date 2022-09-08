#!/bin/bash
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


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
