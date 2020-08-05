#!/bin/bash
./darknet detector test cfg/obj.data cfg/whj_yolov4.cfg backup/whj_yolov4_best.weights -thresh 0.25 -ext_output "$1"
