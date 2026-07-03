#!/usr/bin/env python3

from igfold import IgFoldRunner#, init_pyrosetta

# --- Define ---
HH = "HH119"
clone_nr = "1"
clone_id = "20693_1"

repo_dir = "/Users/srz223/Documents/projects/project_GCbinding/GC_binding_prediction"

# --- File paths ---
heavy_file = f"{repo_dir}/000_prepare/out/{HH}_clone_nr_{clone_nr}_id_{clone_id}_heavy.txt"
light_file = f"{repo_dir}/000_prepare/out/{HH}_clone_nr_{clone_nr}_id_{clone_id}_light.txt"
output_pdb = f"{repo_dir}/001_predicting_antibody_structure/001_igfold/out/{HH}_clone_nr_{clone_nr}_id_{clone_id}_clone.pdb"

# --- Read sequences ---
with open(heavy_file, "r") as f:
    heavy_seq = f.read().strip()

with open(light_file, "r") as f:
    light_seq = f.read().strip()

sequences = {
    "H": heavy_seq,
    "L": light_seq,
}

print(sequences)

# --- Run IgFold ---
# init_pyrosetta()  # uncomment if you want PyRosetta refinement instead of OpenMM

igfold = IgFoldRunner()
igfold.fold(
    output_pdb,
    sequences=sequences,
    do_refine=True,
    do_renum=True,
)

print(f"Structure written to {output_pdb}")
