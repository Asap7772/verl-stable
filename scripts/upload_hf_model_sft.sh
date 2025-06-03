eval "$(conda shell.bash hook)"
conda activate verl

# Set environment variables
hf_cache_dir="/home/anikait.singh/.cache"
export WANDB_API_KEY=a393f29dee9351c0a8c4e410e626e20733564d26
export WANDB_USERNAME=gurpreetkaur94539
export WANDB_USER_EMAIL=gurpreetkaur94539gmail.com
export WANDB__SERVICE_WAIT=300
# export WANDB_ENTITY=cocolab
export HF_DATASETS_CACHE=$hf_cache_dir
export HF_TOKEN='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'

all_local_dirs=(
    # '/home/anikait.singh/rl_behaviors_verl_stable/sft/hintgen-qwen3-4b-sft-1e-5init-star/global_step_180'
    # '/home/anikait.singh/rl_behaviors_verl_stable/sft/hintgen-qwen3-4b-sft-5e-6init-star/global_step_180'
    # '/home/anikait.singh/rl_behaviors_verl_stable/sft/hintgen-qwen3-4b-sft-1e-6init-star/global_step_180'
    # '/home/anikait.singh/rl_behaviors_verl_stable/sft/hintgen-qwen3-4b-sft-5e-7init-star/global_step_180'
    /home/anikait.singh/rl_behaviors_verl_stable/sft/twostagejoint-sft-lr1e-6-0525/global_step_1598
)
num_local_dirs=${#all_local_dirs[@]}

all_target_dirs=(
    # 'Asap7772/hintgen-qwen3-4b-sft-1e-5init-star'
    # 'Asap7772/hintgen-qwen3-4b-sft-5e-6init-star'
    # 'Asap7772/hintgen-qwen3-4b-sft-1e-6init-star'
    # 'Asap7772/hintgen-qwen3-4b-sft-5e-7init-star'
    'Asap7772/twostagejoint-sft-lr1e-6-0525'
)
num_target_dirs=${#all_target_dirs[@]}

if [ $num_local_dirs -ne $num_target_dirs ]; then
    echo "Number of local directories and target directories do not match"
    exit 1
fi

exp_num=0
dry_run=false
which_exp=${1:--1}
if [ $which_exp -eq -1 ]; then
    echo "Running all experiments" 
fi

for i in $(seq 0 $((num_local_dirs - 1))); do
    LOCAL_DIR=${all_local_dirs[$i]}
    TARGET_DIR=${all_target_dirs[$i]}

    command="python /home/anikait.singh/verl-stable/scripts/upload_sft.py \
        --local_dir $LOCAL_DIR \
        --hf_upload_path $TARGET_DIR"
    echo $command
    
    if [ $dry_run = true ]; then
        echo -e "Dry run. Skipping...\n\n"
    else
        eval ${command} &
    fi

    exp_num=$((exp_num+1))
done
wait
