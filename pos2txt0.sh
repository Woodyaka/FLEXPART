#posits_to_txt

#Run with current environment (-V) and in the current directory (-cwd)
#$ -V -cwd

#Request some time- min 15 mins - max 48 hours
#$ -l h_rt=00:15:00

#$ -l h_vmem=5G

#$ -l disk=15G

#Get email at start and end of the job
#$ -m be

module add python

curdir=XRNX/output
dir=/nobackup/py21cb/AIRTRACER/$curdir
mkdir $dir/txts
files=$dir/partposit*

# Loop through the available files and convert them to txt
for INPUT_FILE in $files; do
    echo "[INFO] Subsetting: $INPUT_FILE"
    outfile=$dir/txts/$(echo $INPUT_FILE | cut -c36-100).txt
    python /nobackup/py21cb/templates/read_parposit_2.py $INPUT_FILE $outfile 1
done

module load anaconda
source activate base
python /nobackup/py21cb/templates/txt_merge.py $dir/XRNX_txts/ $dir/XRNX_part_times $dir/XRNX_part_poss
