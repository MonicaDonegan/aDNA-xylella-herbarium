import sys
import argparse
import os 
from glob import glob

def one_line_fasta(input_fasta, one_line_input_fasta):
    "Make sequences from input ALIGNMENT fasta file into a single string"
    with open(input_fasta) as fasta_input, open(one_line_input_fasta, 'w') as fasta_output:
        block = []
        for line in fasta_input:
            if line.startswith('>'):
                if block:
                    string_tmp = ''.join(block) + '\n'
                    fasta_output.write(''.join(block) + '\n')
                    block = []
                fasta_output.write(line)
            else:
                seq=line.strip()
                low_seq=seq.lower()
                seq_dedent = low_seq.replace('-', 'n') #replace gap with p
                block.append(seq_dedent)
        if block:
            string_tmp = ''.join(block) + '\n'
            fasta_output.write(''.join(block) + '\n')
    fasta_output.close()
    return fasta_output

def recombinant_positions(input_recombinant):
    "Makes a list of the recombinant start and end positions from the input file taken from ClonalFrame"
    start_positions_list=[]
    end_positions_list=[]

    with open(input_recombinant, 'r') as positions:
        for line in positions:
            strippedline=line.strip()
            splittedline=strippedline.split()
            start_positions_list.append(splittedline[1])
            end_positions_list.append(splittedline[2])

    del start_positions_list[0]   
    del end_positions_list[0]

    start_positions_list = [int(x) for x in start_positions_list]
    end_positions_list = [int(x) for x in end_positions_list]
    start_positions_list, end_positions_list = (list(x) for x in 
zip(*sorted(zip(start_positions_list, end_positions_list), key=lambda pair: pair[0])))

    recomb_pos_list=[]
    for i in range(len(start_positions_list)) : 
        recom_pos = [*range(start_positions_list[i],end_positions_list[i]+1)]
        recomb_pos_list.extend(recom_pos)

    recomb_pos_list = [*set(recomb_pos_list)]
    recomb_pos_list.sort()
    beg_list = [recomb_pos_list[0]]
    end_list = []
    counter = recomb_pos_list[0]
    for i in recomb_pos_list[1:] : 
        if i == counter + 1: 
            counter = i
            continue
        else: 
            end_list.append(counter)
            beg_list.append(i)
            counter = i
    end_list.append(recomb_pos_list[-1])
    beg_list.reverse()
    end_list.reverse()
    
    return (beg_list, end_list)

def remove_recombinantion(input_fasta,one_line,begin_list, end_list):
    "Removes recombinant segments from core genome alingment"
    one_line = input_fasta.split(".fasta")[0] + "_one_line.fasta"
    removed = one_line.split(".fasta")[0] + "_recombination_removed.fasta"
    
    with open(one_line) as f_input, open(removed, 'w') as f_output:
        block = []
        for line in f_input:
            stripped=line.strip()
            if line.startswith('>'):
                print(line)
                if block:
                    f_output.write(''.join(block) + '\n')
                    block = []
                f_output.write(line)
            else:
                for i,j in zip(begin_list,end_list):
                    stripped = stripped[0:i] + stripped[j+1:]
                block.append(stripped)
        if block:
            f_output.write(''.join(block) + '\n')
    return

def final_function(argv):
    parser = argparse.ArgumentParser(description="Script to remove recombinant regions from alignment.")

    parser.add_argument("-f", "--fasta",
        required = True,
        help = "Your input fasta ALIGNMENT file (*.fasta)")

    parser.add_argument("-r", "--recombinant",
        required = True,
        help = "Your text file with the recombination positions (*.txt)")

    args = parser.parse_args()

    print(args.recombinant)
    print(args.fasta)

    if not os.path.exists(args.fasta) or ".fasta" not in args.fasta:
        print("Couldn't find your file, or it didn't end in \".fasta\"", args.fasta)
        return
    
    if not os.path.exists(args.recombinant) or ".txt" not in args.recombinant:
        print("Couldn't find your file, or it didn't end in \".txt\"", args.recombinant)
        return
    
    input_fasta = args.fasta
    one_line_input_fasta = input_fasta.split(".fasta")[0] + "_one_line.fasta"
    input_recombinant = args.recombinant

    gene_sequence = one_line_fasta(input_fasta, one_line_input_fasta)
    recombinant_list_start, recombinant_list_end = recombinant_positions(input_recombinant)
    remove_recombinantion(input_fasta,gene_sequence, recombinant_list_start,recombinant_list_end)

if __name__ == "__main__":
    final_function(sys.argv)
