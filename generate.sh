#!/bin/bash
set -e

CPX=~/q-e/CPV/src/cp.x
CP_VERSION=6.6

#default values
RESTART_MODE=from_scratch
NSTEPS=100
TSTRESS=.false.
DT=3.0
READ=50
WRITE=51
PSEUDO_DIR=../pseudo
ORTHO=ortho
ELECTRON_DYN=cg
ION_VEL=random
AUTOPILOT=
TEST_NAME=default

function autopilot_element() {
echo "on_step = $1 : $2 = $3 "
}

function autopilot() {

echo AUTOPILOT
while (( "$#"  )); do
	echo $(autopilot_element $1 $2 $3)
    shift 3
done
echo ENDRULES

}

function autopilot_to_verlet() {
	echo "$(autopilot $1 electron_dynamics \'verlet\' $1 orthogonalization \'ortho\' ${@:2} )"
}

function autopilot_change_dt() {
	echo "$(autopilot $1 dt $2)"
}

function generate_input() {

cat > $1 << EOF
  &CONTROL
    calculation='cp',
    title="WATER",
    restart_mode='${RESTART_MODE}',
    nstep=${NSTEPS},
    tstress=${TSTRESS},
    dt = ${DT},
    ndr=${READ},
    ndw=${WRITE},
    pseudo_dir='${PSEUDO_DIR}',
    outdir='./out',
  /
  &SYSTEM
    ibrav = 1,
    celldm(1) = 10.,
    nat =3,
    ntyp =2,
    ecutwfc =80.0,
  /
  &ELECTRONS
    emass = 50.,
    emass_cutoff = 3.,
    orthogonalization = '${ORTHO}',
    electron_dynamics= '${ELECTRON_DYN}',
  /
  &IONS
    ion_dynamics    = 'verlet',
    ion_velocities= '${ION_VEL}',
    tempw=800,
  /
${AUTOPILOT}
ATOMIC_SPECIES
   H      1.00000000 H_HSCV_PBE-1.0.upf
   O     16.00000000 O_HSCV_PBE-1.0.upf
ATOMIC_POSITIONS {bohr}
 H     0.57164238	  0.94335166	  0.96565043
 H    -0.24339682	 -0.43501513	 -1.37874473
 O    -0.32824556	 -0.50852550	  0.41309430
EOF
}

PDIR="$(pwd)"
AIIDA_TEST_D="$PDIR/aiida"

for f in test_*.sh ; do
	cd "$PDIR"
	source $f
	echo ================
	echo TEST: $TEST_NAME
	echo ================
	DIR="${CP_VERSION}_$TEST_NAME"
	if [ -e "$DIR" ]
	then
		echo "error: '$DIR' exists"
		continue
	fi

	mkdir "$PDIR/${DIR}"
	cd "$PDIR/${DIR}"
	if [ -e "../prepare_$f" ]
	then
		source "../prepare_$f"
		source "$PDIR/$f"
	fi
	generate_input aiida.in
	"${CPX}" -in aiida.in | tee aiida.out
	if [ -e "$AIIDA_TEST_D/$DIR" ]
	then
		echo REMOVING $AIIDA_TEST_D/$DIR
		rm -rv "$AIIDA_TEST_D/$DIR"
	fi
	mkdir -p "$AIIDA_TEST_D/$DIR"
	cd "$AIIDA_TEST_D/$DIR"
	"$PDIR/retrieve_cp_output.sh" "$PDIR/${DIR}/out" cp $WRITE

done
