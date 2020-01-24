import json
import os
import pandas as pd


def to_json(obj, pretty=True):
    class DefaultEncoder(json.JSONEncoder):
        def default(self, o):
            return o.__dict__

    return json.dumps(cls=DefaultEncoder, obj=obj, indent=2 if pretty else None)


local_folder = 'vods/gfuel_custom'
datas = []
with open('vods/gfuel_custom/transcript.txt', "r") as f:
    lines = f.readlines()
for num, line in enumerate(lines):
    # print(num, line)
    filename = '{}.wav'.format(num+1)
    datas.append({
        'wav_filename': '/root/speech/data/gfuel_custom/{}'.format(filename),
        'wav_filesize': os.path.getsize('{}/{}'.format(local_folder, filename)),
        'transcript': line.strip()
    })
df = pd.read_json(to_json(datas)).reindex(columns=['wav_filename', 'wav_filesize', 'transcript'])
df.to_csv(os.path.join(local_folder, "gfuel_custom.csv"), index=False)



