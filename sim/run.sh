#run.sh b UVM_LOW ahb_f apb_f testname
#run.sh g UVM_LOW ahb_f apb_f testname


function help()
{
cat << EOF
#  ========================  Batch Mode  ========================
#  =      ~~~~  Format  ~~~~                                    =
#  =      run.sh b verbosity ahb_freq apb_freq testname         =
#  =                                                            =
#  =      ~~~~  Example  ~~~~                                   =
#  =      run.sh b UVM_LOW 400 100 single_write_read_test       =
#  ==============================================================



#  =========================  GUI Mode  =========================
#  =      ~~~~  Format  ~~~~                                    =
#  =      run.sh g verbosity ahb_freq apb_freq testname         =
#  =                                                            =
#  =      ~~~~  Example  ~~~~                                   =
#  =      run.sh g UVM_LOW 400 100 single_write_read_test       =
#  ==============================================================



#  =========================  COV Mode  =========================
#  =      ~~~~  Format  ~~~~                                    =
#  =      run.sh g verbosity ahb_freq apb_freq testname         =
#  =                                                            =
#  =      ~~~~  Example  ~~~~                                   =
#  =      run.sh g UVM_LOW ahb_freq 400 b 100 single_write_read_test       =
#  =                                                            =
#  =      ~~~~    Try    ~~~~                                   =
#  =      run.sh c verbosity ahb_freq apb_freq testname         =
#  ==============================================================
EOF
}

#function echo_repeat()
#{
#    # usage: echo_repeat string num new_line(1)
#    for i in $(seq 1 $2); do printf "%s" "$1"; done
#    # print a newline only if the  3rd argument is 1
#    new_line=$3
#    [[ "$new_line" == 1 ]] && echo ""  #echo $new_line
#}




AHB_frequency=400
APB_frequency=100

regression_single_test_count=5

VERBOSITY="UVM_LOW"

if [[ -d INCA_libs ]];
then
    rm -r ./INCA_libs/ && echo "INCA_libs deleted"
fi

#4 types of RUN_Mode :: b   :: Test Result in Terminal
#                    :: g   :: Show Wave   in Gui Mode
#                    :: c   :: Coverage Test
#                    :: r   :: Regression Test

    RUN_MODE=$1;  #4 types of RUN_Mode [[b, g, c, r]]
    VERBOSITY=$2; #UVM_VERBOSITY [[ UVM_NONE for covarage ]]
    
    #AHB_frequency=$3; #which test to run [[ apb_cons_wr_test, apb_sequential_wr_test ]]
    #APB_frequency=$4; #which test to run [[ apb_cons_wr_test, apb_sequential_wr_test ]]
    
    TEST_NAME=$3; #which test to run [[ apb_cons_wr_test, apb_sequential_wr_test ]]

AHB_frequency=400
APB_frequency=100

regression_single_test_count=5

VALID_ARGS=$(getopt -o a:b:hr: --long ahb_freq:,apb_freq:,help,reg_count: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ true ]; do
  case "$1" in
    a | --ahb_freq)
        AHB_frequency=$2;
        echo "AHB Frequency is : '$AHB_frequency'"
        shift 2
        ;;
    b | --apb_freq)
        APB_frequency=$2;
        echo "APB Frequency is : '$APB_frequency'"
        shift 2
        ;;
    r | --reg_count)
        regression_single_test_count=$2;
        echo "Regression_single_test_count : '$regression_single_test_count'"
        shift 2
        ;;
    -h | --help)
        help
        shift
        ;;
    --) shift; 
        break 
        ;;
  esac
done






if [[ "$RUN_MODE" == "b" ]];
then
#echo "batch_mode is called";
    echo ""
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo "%%%%%%%%%%%%%  Batch Mode  %%%%%%%%%%%%%";
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo ""
    echo "AHB_frequency=$AHB_frequency"
    echo "APB_frequency=$APB_frequency"
    

# $value$plusargs
#irun -timescale 1ns/1ps -f filelist.f -access +rwc -uvm -svseed random \
#+UVM_VERBOSITY=$VERBOSITY +UVM_TESTNAME=$TEST_NAME \
#+AHB_frequency=$AHB_frequency +APB_frequency=$APB_frequency

# -define arg=value
    irun -timescale 1ns/1ps -f filelist.f -access +rwc -uvm -svseed random -disable_sem2009 \
    +UVM_VERBOSITY=$VERBOSITY \
    +UVM_TESTNAME=$TEST_NAME \
    -define AHB_frequency=$AHB_frequency \
    -define APB_frequency=$APB_frequency


elif [[ "$RUN_MODE" == g ]]
then
#echo "gui_mode is called";
    echo ""
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo "%%%%%%%%%%%%%%  Gui Mode  %%%%%%%%%%%%%%";
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo ""

    # $value$plusargs
    #irun -timescale 1ns/1ps -f filelist.f -access +rwc -uvm -svseed random \
    #+UVM_TESTNAME=$TEST_NAME \
    #+AHB_frequency=$AHB_frequency \
    #+APB_frequency=$APB_frequency \
    #+UVM_VERBOSITY=$VERBOSITY -gui &

# -define arg=value
    irun -timescale 1ns/1ps -f filelist.f -access +rwc -uvm -svseed random \
    +UVM_TESTNAME=$TEST_NAME \
    +UVM_VERBOSITY=$VERBOSITY \
    -define AHB_frequency=$AHB_frequency \
    -define APB_frequency=$APB_frequency -gui
    
    

#  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#bash run.sh c_g UVM_LOW 400 100 Experimental_test
elif [[ "$RUN_MODE" == c_g ]] # new # iccr // single coverage // in // gui + load
then
    
    seed_value="$RANDOM";
    test_name_random_seed="$TEST_NAME"_"$seed_value";
    
    
    
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo "%%%%%%%%%%%%  Coverage Mode  %%%%%%%%%%%%";
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo "%%%%%%%%  $test_name_random_seed  %%%%%%%";
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo ""
    

    find . -maxdepth 1 -type d -name 'html_*' -exec cp -R '{}' ./Store_Single_html_folder/ \; | echo "HTML folder copied"
    find . -maxdepth 1 -type d -name 'html_*' -exec rm -rf {} +


    if [[ -d cov_work ]];
    then
        rm -r ./cov_work/ && echo "cov_work folder deleted"
    fi

    
    irun -sem2009 +UVM_NO_RELNOTES -uvm \
    -f filelist.f \
    -timescale 1ns/1ps \
    -access +rwc \
    +UVM_TESTNAME=$TEST_NAME \
    +UVM_VERBOSITY=$VERBOSITY \
    -define AHB_frequency=$AHB_frequency \
    -define APB_frequency=$APB_frequency \
    -seed $seed_value \
    -covtest $test_name_random_seed \
    -coverage all
    
    bash cmd.cmd $test_name_random_seed
    

#  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#bash run.sh c_g_ex UVM_LOW 400 100 Experimental_test
elif [[ "$RUN_MODE" == c_g_ex ]] # new # iccr // single test coverage // in // gui + load  // include exclution list
then

    seed_value="$RANDOM";
    test_name_random_seed="$TEST_NAME"_"$seed_value";
    
    echo ""
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo "%%%%%%%%%%%%  Coverage Mode  %%%%%%%%%%%%";
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo "%%%%%%%%  $test_name_random_seed  %%%%%%%";
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo ""

    find . -maxdepth 1 -type d -name 'html_*' -exec cp -R '{}' ./Store_Single_html_folder/ \; | echo "HTML folder copied"
    find . -maxdepth 1 -type d -name 'html_*' -exec rm -rf {} +


    if [[ -d cov_work ]];
    then
        rm -r ./cov_work/ && echo "cov_work folder deleted"
    fi

    
    irun -sem2009 +UVM_NO_RELNOTES -uvm \
    -f filelist.f \
    -timescale 1ns/1ps \
    -access +rwc \
    +UVM_TESTNAME=$TEST_NAME \
    -define AHB_frequency=$AHB_frequency \
    -define APB_frequency=$APB_frequency \
    -seed $seed_value \
    +UVM_VERBOSITY=$VERBOSITY \
    -covtest $test_name_random_seed \
    -coverage all \
    -covfile toggle_exclude.ccf
    
    cp ./irun.log ./results_4/$test_name_random_seed.log
    
    # bash cmd.cmd $test_name_random_seed
    iccr -test ./cov_work/scope/$test_name_random_seed mark_gui.cmd
    #load_icf saved_marks.icf    # in cmd file
    

elif [[ "$RUN_MODE" == c ]] # new # iccr
then

    seed_value="$RANDOM";
    test_name_random_seed="$TEST_NAME"_"$seed_value";
    
    
    echo ""
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo "%%%%%%%%%%%%  Coverage Mode  %%%%%%%%%%%%";
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo "%%%%%%%%  $test_name_random_seed  %%%%%%%";
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo ""

    find . -maxdepth 1 -type d -name 'html_*' -exec cp -R '{}' ./Store_Single_html_folder/ \; | echo "HTML folder copied"
    find . -maxdepth 1 -type d -name 'html_*' -exec rm -rf {} +


    if [[ -d cov_work ]];
    then
        rm -r ./cov_work/ && echo "cov_work folder deleted"
    fi


    irun -sem2009 +UVM_NO_RELNOTES -uvm \
    -f filelist.f \
    -timescale 1ns/1ps \
    -access +rwc \
    +UVM_TESTNAME=$TEST_NAME \
    -define AHB_frequency=$AHB_frequency \
    -define APB_frequency=$APB_frequency \
    -seed $seed_value \
    -covtest $test_name_random_seed \
    -coverage all
    
    cp ./irun.log ./results_4/$test_name_random_seed.log
    
    #\
    #-covfile toggle_exclude.ccf
    
    #iccr iccr_single_coverage.cmd
    #firefox html*/index.html &


elif [[ "$RUN_MODE" == c_r ]] # new # iccr  #coverage regression
then

    seed_value="$RANDOM";
    test_name_random_seed="$TEST_NAME"_"$seed_value";

    echo ""
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo "%%%%%%%%%%%%  Coverage Mode  %%%%%%%%%%%%";
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
	echo "%%%%%%%%  $test_name_random_seed  %%%%%%%";
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo ""
    

    irun -sem2009 +UVM_NO_RELNOTES -uvm \
    -f filelist.f \
    -timescale 1ns/1ps \
    -access +rwc \
    +UVM_TESTNAME=$TEST_NAME \
    +UVM_VERBOSITY=$VERBOSITY \
    -define AHB_frequency=$AHB_frequency \
    -define APB_frequency=$APB_frequency \
    -seed $seed_value \
    -covtest $test_name_random_seed \
    -covfile toggle_exclude.ccf \
    -coverage all
    
    #\
    #-covfile toggle_exclude.ccf    
    
    cp ./irun.log ./results_5/$test_name_random_seed.log

elif [[ "$RUN_MODE" == r ]] #updated # for iccr
then

    echo ""
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo "%%%%%%%%%%%  Regression Mode  %%%%%%%%%%%";
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo ""
    
    [[ -d ./cov_work/ ]] && rm -r cov_work/ && echo "cov_work folder deleted"

    find . -maxdepth 1 -type d -name 'html_*' -exec cp -R '{}' ./store_html_folders/ \; | echo "HTML folder copied"
    find . -maxdepth 1 -type d -name 'html_*' -exec rm -rf {} +
    
    declare -a all_test=();
    
    #all_test=`ls ../tb/test_lib/ | grep -v '._base_test.sv\|.sv~\|._pkg\|Experimental_test.sv' | cut -f 1 -d '.'`;
    all_test=`ls ../tb/test_lib/ | grep -v '._base_test.sv\|.sv~\|._pkg' | cut -f 1 -d '.'`;
    
    
    #echo $all_test
    
    for ((j=1; j<=$regression_single_test_count; j++))
    do
        ahb_rand_freq=$((($RANDOM%400)+1));
        apb_rand_freq=$((($RANDOM%100)+1));
        
       for i in $all_test
       do
            echo "........Running ${i} for ( ${j} time ) AHB_freq :: $ahb_rand_freq,  APB_freq :: $apb_rand_freq......."
            bash ./run.sh c_r $VERBOSITY $i --ahb_freq $ahb_rand_freq --apb_freq $apb_rand_freq
        done
    done
    
    iccr iccr_merge_coverage.cmd
    #firefox html*/index.html &
    
   
elif [[ "$RUN_MODE" == coverage ]] #OLD # imc
then
#echo "coverage_mode is called";
    echo ""
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo "%%%%%%%%%%%%  Coverage Mode  %%%%%%%%%%%%";
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo ""


    if [[ -d cov_work ]];
    then
        rm -r ./cov_work/ && echo "cov_work deleted"
    fi

    # irun -timescale 1ns/1ps -f filelist.f -access +rwc -uvm +UVM_TESTNAME=$TEST_NAME +UVM_VERBOSITY=UVM_NONE -coverage all -covtest $TEST_NAME > temp.log
    
    # mahade vai
    irun -sem2009 +UVM_NO_RELNOTES -uvm -f filelist.f -timescale 1ns/1ps +UVM_TESTNAME=$TEST_NAME -seed random -covtest $TEST_NAME -coverage all -covfile ./cov_file.ccf > temp.log


elif [[ "$RUN_MODE" == reg ]]
then

    echo ""
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo "%%%%%%%%%%%  Regression Mode  %%%%%%%%%%%";
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
    echo ""


    [[ -d ./cov_work/ ]] && rm -r cov_work/ && echo "cov_work  deleted"


    filename='testfile.txt'
    echo Start

    mapfile -t Array < testfile.txt

    ELEMENTS=${#Array[@]}

    for (( i=0;i<$ELEMENTS;i++)); do
        echo ${Array[${i}]}
        bash run.sh cov ${Array[${i}]} UVM_NONE
    done

    # imc -execcmd "merge -runfile testfile.txt -out merged_results"

    # imc -load /home/Mo220206/work/uvm/switch/sim/cov_work/scope/merged_results &


else

    help
#    echo "Run Mode type error."
#    echo ""
#    echo "b   :: batch Mode"
#    echo "g   :: Gui Mode"
#    echo "c   :: Coverage Test"
#    echo "
#========================  Batch Mode  ========================
#=      ~~~~  Format  ~~~~                                    =
#=      run.sh b verbosity ahb_freq apb_freq testname         =
#=                                                            =
#=      ~~~~  Example  ~~~~                                   =
#=      run.sh b UVM_LOW 400 100 single_write_read_test       =
#==============================================================



#=========================  GUI Mode  =========================
#=      ~~~~  Format  ~~~~                                    =
#=      run.sh g verbosity ahb_freq apb_freq testname         =
#=                                                            =
#=      ~~~~  Example  ~~~~                                   =
#=      run.sh g UVM_LOW 400 100 single_write_read_test       =
#=============================================================="
    
    
    


    

fi

#script cov testname UVM_LOW


