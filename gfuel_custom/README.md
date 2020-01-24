
# TRAINING 

## Language Model

```
cd root@speech:~/speech/data/gfuel_custom
../../kenlm/build/bin/lmplz --text transcript.txt --arpa words.arpa --o 3 --discount_fallback
../../kenlm/build/bin/build_binary -T -s words.arpa lm.binary
../../native_client/generate_trie alphabet.txt lm.binary trie
```

## Voice Training

```
cd ~/speech/DeepSpeech
python3 -u DeepSpeech.py --noshow_progressbar \
  --train_files ../data/gfuel_custom/gfuel_custom.csv \
  --test_files ../data/gfuel_custom/gfuel_custom.csv \
  --train_batch_size 10 \
  --dev_batch_size 10 \
  --test_batch_size 5 \
  --n_hidden 375 \
  --epochs 33 \
  --validation_step 1 \
  --early_stop True \
  --earlystop_nsteps 6 \
  --estop_mean_thresh 0.1 \
  --estop_std_thresh 0.1 \
  --dropout_rate 0.22 \
  --learning_rate 0.00095 \
  --report_count 100 \
  --use_seq_length False \
  --checkpoint_dir ../data/gfuel_custom/checkpoint \
  --alphabet_config_path ../data/gfuel_custom/alphabet.txt \
  --lm_binary_path ../data/gfuel_custom/lm.binary \
  --lm_trie_path ../data/gfuel_custom/trie \
  --export_dir ../data/gfuel_custom/
``` 

# TESTING 

