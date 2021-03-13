#/bin/bash
find config.d -type f -exec awk '{print}' {} +  > ./config