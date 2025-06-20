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

models=(
    /home/anikait.singh/rl_behaviors_verl_stable/sft/insight-qwen3-1.7b-sft-0510/global_step_370
    /home/anikait.singh/rl_behaviors_verl_stable/sft/insight-qwen2.5-3b-sft-0510/global_step_370
)
num_models=${#models[@]}
names=(
    insight-qwen3-1.7b-grpo-0527
    insight-qwen2.5-3b-grpo-0527
)
num_names=${#names[@]}

train_data_dirs=(
    "/home/anikait.singh/rl_behaviors_verl_stable/data_insights_rl_v3"
    "/home/anikait.singh/rl_behaviors_verl_stable/data_insights_rl_v3"
)
num_train_data_dirs=${#train_data_dirs[@]}

eval_data_dirs=(
    "/home/anikait.singh/rl_behaviors_verl_stable/data_insights_rl_v3"
    "/home/anikait.singh/rl_behaviors_verl_stable/data_insights_rl_v3"
)
num_eval_data_dirs=${#eval_data_dirs[@]}

gpus=(
    "0,1,2,3,4,5,6"
    "0,1,2,3,4,5,6"
)
num_gpus=${#gpus[@]}

PROJECT_NAME='insight-new-grpo-0527'


if [ $num_models -ne $num_names ]; then
    echo "Number of models and names should be the same"
    exit 1
fi

if [ $num_models -ne $num_gpus ]; then
    echo "Number of models and gpus should be the same"
    exit 1
fi

if [ $num_models -ne $num_train_data_dirs ]; then
    echo "Number of models and data directories should be the same"
    exit 1
fi

if [ $num_models -ne $num_eval_data_dirs ]; then
    echo "Number of models and eval data directories should be the same"
    exit 1
fi

exp_num=0
dry_run=false
which_exp=${1:--1}
if [ $which_exp -eq -1 ]; then
    echo "Running all experiments" 
fi

for i in $(seq 0 $((num_models-1))); do
    if [ $which_exp -ne -1 ] && [ $exp_num -ne $which_exp ]; then
        exp_num=$((exp_num+1))
        continue
    fi

    curr_train_data_dir=${train_data_dirs[$i]}
    curr_eval_data_dir=${eval_data_dirs[$i]}
    if [ ! -d $curr_train_data_dir ]; then
        echo "Data directory $curr_train_data_dir does not exist"
        exit 1
    fi
    if [ ! -d $curr_eval_data_dir ]; then
        echo "Data directory $curr_eval_data_dir does not exist"
        exit 1
    fi

    export N_GPUS=7
    export BASE_MODEL=${models[$i]}
    export TRAIN_DATA_DIR=$curr_train_data_dir
    export EVAL_DATA_DIR=$curr_eval_data_dir
    export ROLLOUT_TP_SIZE=2
    export EXPERIMENT_NAME=${names[$i]}
    export VLLM_ATTENTION_BACKEND=XFORMERS
    export CUDA_VISIBLE_DEVICES=${gpus[$i]}
    export PROJECT_NAME=$PROJECT_NAME
    export MAX_MODEL_LEN=2048
    export MAX_PROMPT_LENGTH=1280
    export EPOCHS=2

    command="bash /home/anikait.singh/verl-stable/scripts/grpo/grpo_run_insight.sh"
    echo "Using GPU: $CUDA_VISIBLE_DEVICES"
    echo $command
    if [ $dry_run = true ]; then
        echo -e "Dry run. Skipping...\n\n"
    else
        eval $command
    fi
    
    exp_num=$((exp_num+1))
done
