#!/bin/bash
./darknet detector train cfg/obj.data cfg/whj_yolov4.cfg backup/whj_yolov4_last.weights -dont_show -map -gpus 0,1,2,3
