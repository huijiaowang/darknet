#!/bin/bash
CUDA_VISIBLE_DEVICES=3  ./darknet detector train cfg/human_detector.data cfg/human_detector_yolov4.cfg csdarknet53-omega.conv.105 -dont_show -map
