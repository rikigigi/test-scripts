RESTART_MODE=from_scratch
NSTEPS=30
TSTRESS=.false.
DT=10.0
READ=50
WRITE=51
PSEUDO_DIR=../pseudo
ORTHO=ortho
ELECTRON_DYN=cg
ION_VEL=random
AUTOPILOT="$(autopilot_to_verlet 20 20 dt 3.d0 )"
TEST_NAME=verlet

generate_input aiida_pre.in
"${CPX}" -in aiida_pre.in | tee aiida_pre.out
rm out/cp.* -v

