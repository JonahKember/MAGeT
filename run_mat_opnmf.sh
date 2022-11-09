#!/bin/bash
#SBATCH --time=00:25:00
#SBATCH --nodes=1
#SBATCH --account=rrg-chai
#SBATCH --ntasks 80

module load matlab/2022a
matlab -nodisplay -singleCompThread -r "create_nmf_input"
matlab -nodisplay -singleCompThread -r "generic_niagara_pnmf"
matlab -nodisplay -singleCompThread -r "W_to_niftii"
