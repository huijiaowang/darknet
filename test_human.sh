#!/bin/bash
#./darknet detector test cfg/coco.data cfg/yolov4.cfg yolov4.weights -thresh 0.25 -ext_output "$1"
# 71%
#./darknet detector test cfg/obj.data cfg/whj_yolov4.cfg backup_0803/whj_yolov4_2000.weights -thresh 0.25 -ext_output "$1"

./darknet detector test cfg/obj.data cfg/whj_yolov4.cfg backup/whj_yolov4_best.weights -thresh 0.25 -ext_output "$1"
