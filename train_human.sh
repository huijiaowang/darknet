#!/bin/bash
CUDA_VISIBLE_DEVICES=0  ./darknet detector train cfg/obj.data cfg/whj_yolov4.cfg csdarknet53-omega.conv.105 -dont_show -map
