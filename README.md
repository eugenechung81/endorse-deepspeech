
# Installation

Deployed on DigitalOcean Ubuntu 16.04
```
ssh root@192.241.155.8
```

## Docker Instructions 

```
docker build -t speech:latest . 
docker run -v ${PWD}/models:/app/models -v ${PWD}/audio:/app/audio -it speech:latest /bin/bash
# after making changes
docker commit <container_id> speech:latest
```


### Install DeepSpeech and dependencies

```
# Follow steps in Dockerfile

# Download pretrained model
mkdir models/ 
wget https://github.com/mozilla/DeepSpeech/releases/download/v0.5.1/deepspeech-0.5.1-models.tar.gz
tar xvfz deepspeech-0.5.1-models.tar.gz 
mv deepspeech-0.5.1-models models/pretrained_model/

# Prep audio file 
mkdir audio/
ffmpeg -i input.mp3 output.wav 
ffmpeg -i test.mp3 -acodec pcm_s16le -ar 16000 -ac 1 test_1_channel.wav 

# Traverse to model directory and to run transcription
deepspeech --model output_graph.pbmm --alphabet alphabet.txt --lm lm.binary --trie trie --audio <wav_file>
# e.g. LDC93S1.wav
# she had educatin greasy wat for a year (incorrect)
```

## Training

### Run Training

```
# import from /bin directory 
/app/DeepSpeech# ./bin/import_ldc93s1.py data/ldc93s1/

# Run training 
./bin/run-ldc93s1.sh --export_dir ../models/ldc93s1/
python3 -u DeepSpeech.py --noshow_progressbar \
  --train_files ../texts/gfuel_mentions.csv \
  --test_files ../texts/gfuel_mentions.csv \
  --train_batch_size 3 \
  --test_batch_size 3 \
  --n_hidden 100 \
  --epochs 200 \
  --checkpoint_dir /tmp/gfuel_mentions \
  --alphabet_config_path ../models/gfuel_model/alphabet.txt \
  --lm_binary_path ../models/gfuel_model/lm.binary \
  --lm_trie_path ../models/gfuel_model/trie \
  --export_dir "../models/gfuel_model/"
# outputs models/output_graph.pb
# test with model again
```


### Training - Fine Tuning Model 

```
python3 -u DeepSpeech.py --noshow_progressbar \
  --train_files ../texts/gfuel_mentions.csv \
  --test_files ../texts/gfuel_mentions.csv \
  --train_batch_size 3 \
  --dev_batch_size 3 \
  --test_batch_size 3 \
  --n_hidden 2048 \
  --learning_rate 0.0001 \
  --dropout-rate 0.15 \
  --epochs 75 \
  --checkpoint_dir ../models/fine_tuning_model/checkpoint \
  --alphabet_config_path ../models/fine_tuning_model/models/alphabet.txt \
  --lm_binary_path ../models/fine_tuning_model/models/lm.binary \
  --lm_trie_path ../models/fine_tuning_model/models/trie \
  --export_dir "../models/fine_tuning_model/"
# test with model again  
```

************************************************************************************

## Making custom vocab

### Preparation 

```
# install dependencies
apt-get -y install cmake libboost-all-dev build-essential libboost-all-dev cmake zlib1g-dev libbz2-dev liblzma-dev
export EIGEN3_ROOT=$HOME/eigen-eigen-07105f7124f9 && \
    (cd $HOME; wget -O - https://bitbucket.org/eigen/eigen/get/3.2.8.tar.bz2 |tar xj) && \
    rm CMakeCache.txt

# download native client for generate_trie
wget https://github.com/mozilla/DeepSpeech/releases/download/v0.5.1/native_client.amd64.cpu.linux.tar.xz
tar xvf native_client.amd64.cpu.linux.tar.xz 

# create build for kenlm
git clone https://github.com/kpu/kenlm
mkdir -p build
cd build
cmake ..
make -j 4
```

### Creating Language Model 

```
mkdir working
cd working/
mkdir training_material
mkdir language_models

cd training_material/
vi vocabulary.txt

# build arpa
build/bin/lmplz --text working/training_material/vocabulary.txt --arpa working/language_models/words.arpa --order 5 --discount_fallback --temp_prefix /tmp/

# build binary
build/bin/build_binary -T -s trie working/language_models/words.arpa working/language_models/lm.binary

# build trie 
../native_client/generate_trie ../DeepSpeech/data/alphabet.txt working/language_models/lm.binary working/language_models/trie
```

### Test New Language Model

```
# must also build your own model 
deepspeech --model ../DeepSpeech/models/output_graph.pb --alphabet ../DeepSpeech/data/alphabet.txt --lm working/language_models/lm.binary --trie working/language_models/trie --audio ../../test3.wav
```

## Transcribing Large File (using VAD) 

```
root@speech:~/speech/DeepSpeech/examples/vad_transcriber

source venv/bin/activate
python3 audioTranscript_cmd.py --aggressive 1 --audio ../../../test_1_channel.wav --model ../../../models/
```

## Transcribing with Timestamp 

Must be in `vnev` environment.  

```
(venv) root@speech:~/speech# ./native_client/deepspeech \
	--model DeepSpeech/models/output_graph.pb \
	--alphabet models/alphabet.txt \
	--lm models/lm.binary \
	--trie models/trie \
	--json \
	--audio LDC93S1.wav
{"metadata":{"confidence":74.7832},"words":[{"word":"she","time":0,"duration":0.08},{"word":"had","time":0.1,"duration":0.06},{"word":"your","time":0.2,"duration":1.72},{"word":"dark","time":1.96,"duration":0.1},{"word":"suit","time":2.1,"duration":0.0800002},{"word":"in","time":2.2,"duration":0.0599999},{"word":"greasy","time":2.28,"duration":0.14},{"word":"wash","time":2.44,"duration":0.0999999},{"word":"water","time":2.56,"duration":0.12},{"word":"all","time":2.7,"duration":0.12},{"word":"year","time":2.84,"duration":0.0599999}]}
```
