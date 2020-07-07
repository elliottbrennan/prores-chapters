#!/bin/bash
echo "path to mkv"

read INPUT

ffprobe "$INPUT" 2>&1 |
sed -En 's/.*Chapter #([0-9]+)[.:]([0-9]+): start ([0-9]+\.[0-9]+), end ([0-9]+\.[0-9]+).*/\1.\2 \3 \4/p' |
while read chapter start end
do

    ffmpeg </dev/null \
        -i "$INPUT" \
		-c:v prores_ks \
		-profile:v 5 \
		-quant_mat hq \
		-max_muxing_queue_size 1024 \
		-pix_fmt yuv422p10le -color_primaries bt2020 -colorspace bt2020_ncl -color_trc smpte2084 -movflags +write_colr -strict experimental \
		-c:a pcm_s16le -ac 2 \
		-map 0:0 -map 0:1 \
        -ss "$start" -to "$end" \
        "${INPUT%.*}-chapter-$chapter.mov"

done
