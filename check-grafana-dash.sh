#!/bin/bash

TMP_NS_FILE='/tmp/nslist'

cleanup_action () {
    rm -f $TMP_NS_FILE > /dev/null 2>&1
    exit 1
}


kubectl get ns | tail -n +2 | awk '{ print $1 }' > $TMP_NS_FILE
if [ $? -ne 0 ]
then
    echo `date`": ERROR: Cant list NameSpaces"
    cleanup_action
fi

while read ns
do
    # Get Kubernetes ConfigMaps with Grafana Dashboards
    cms=$(kubectl get cm -n $ns -l grafana_dashboard="1" 2> /dev/null | tail -n +2 | awk '{ print $1 }' )
    if [ -z "$cms" ];
    then
        continue
    fi
    for cm in $cms
    do
        cm_data=$(kubectl get cm -n $ns $cm -o jsonpath='{.data}' | jq -c 'keys' | cut -c 3- | rev | cut -c 3- | rev)
        IFS='","' read -ra DASHS <<< $cm_data
        for dash_name in $DASHS; 
        do
            clear_dash_name=$(echo $dash_name | sed 's/\./\\./g')
            dash=$(kubectl get cm -n $ns $cm -o jsonpath="{.data.$clear_dash_name}")
            error=$(echo $dash | jq '.Error')
            if [[ "$error" != "null" ]];
            then
                echo "NameSpace: $ns. ConfigMap: $cm. Have Error!!!"
            fi
        done
    done
done < $TMP_NS_FILE