import sys
from array import *

INSTRUCTIONS = {
        'R-TYPE': {
            'SLL': {'funct':'000000'},
            'SRL': {'funct':'000010'},
            'SRA': {'funct':'000011'},
            'SLLV': {'funct':'000100'},
            'SRLV': {'funct':'000110'},
            'SRAV': {'funct':'000111'},
            'ADDU': {'funct':'100001'},
            'SUBU': {'funct':'100011'},
            'XOR': {'funct':'100110'},
            'AND': {'funct':'100100'},
            'OR': {'funct':'100101'},
            'XOR': {'funct':'100110'},
            'NOR': {'funct':'100111'},
            'SLT': {'funct':'101010'},
        },

        'I-TYPE' : {
            'MEMORY':{
                'LB': {'opcode':'100000'},
                'LH': {'opcode':'100001'},
                'LW': {'opcode':'100011'},
                'LWU': {'opcode':'100111'},
                'LBU': {'opcode':'100100'},
                'LHU': {'opcode':'100101'},
                'SB': {'opcode':'101000'},
                'SH': {'opcode':'101001'},
                'SW': {'opcode':'101011'}
            },
            'INMEDIATE':{
                'ADDI': {'opcode':'001000'},
                'ANDI': {'opcode':'001100'},
                'ORI': {'opcode':'001101'},
                'XORI': {'opcode':'001110'},
                'LUI': {'opcode':'001111'},
                'SLTI': {'opcode':'001010'},
                'BEQ': {'opcode':'000100'},
                'BNE': {'opcode':'000101'}
                
            },
            'INST_INDEX':{
                'J': {'opcode':'000010'},
                'JAL': {'opcode':'000011'}
            }
            
        },

        'J-TYPE': {
            'JR': {'funct':'001000'},
            'JALR': {'funct':'001001'},
        }
    }

if __name__ == "__main__":
    #print('Number of arguments:', len(sys.argv), 'arguments.')

    if (len(sys.argv) < 4) or ('-i' not in sys.argv) or ('-o' not in sys.argv):
	    print('Usage: python Assembler.py -i <inputfile.asm> -o <outputfile.hex>')
	    sys.exit(2)

    input_file_path = sys.argv[sys.argv.index('-i') + 1]
    output_file_path_hexa_txt = sys.argv[sys.argv.index('-o') + 1] + '_hex.txt'
    output_file_path_bin = sys.argv[sys.argv.index('-o') + 1] + '.bin'
    output_file_path_bin_txt = sys.argv[sys.argv.index('-o') + 1] + '_bin.txt' 

    print(input_file_path)
    print(output_file_path_bin)

    #leer archivo y guardar lineas
    input_file = open(input_file_path,'r')
    input_lines = input_file.readlines()
    input_file.close()

    #a cada linea, se convierte a lista, cada elemento es cada simbolo separado por espacios
    input_lines_list=[]
    for line in input_lines:
        input_lines_list.append(line.splitlines()[0].split())

    print(input_lines_list)

    #guardar nombre de los label y el indece de instruccion al q apuntan
    labels={}
    for line in input_lines_list:
        #print(len(line))
        if(len(line)==1 and (line[0] != 'nop' and line[0] != 'halt' and line[0] != 'NOP' and line[0] != 'HALT')): #un solo simbolo se toma como label (si no es nop ni halt)
            labels[line[0].replace(":",'')]=input_lines_list.index(line)-len(labels)

    #print(labels)

    output_lines_bin = []
    output_lines_hexa = []
    bin_bytes = []
    #se quitan los labels
    input_lines_list = [line for line in input_lines_list if len(line) > 1 or line[0] == "nop" or line[0] == "halt" or line[0] == "NOP" or line[0] == "HALT"]
    #se recorren las lineas
    #print(input_lines_list)
    for line in input_lines_list:
        
        #el primer elemento de la linea es el nombre de la instucion
        instruction_name = line[0]
        print(instruction_name)
        #los siguiente componentes de la linea son los operandos formato r1, offset(base) o valor
        operands = []
        #se quita el r y las , 
        for operand in line [1:]:
            operands.append(operand.replace("r","").replace(",",'').replace("R",""))

        #print(operands)

        if(instruction_name in INSTRUCTIONS['R-TYPE'].keys()):
            op_code = "000000"
            shamt = "00000"
            #campo funct de cada instruccion
            function = INSTRUCTIONS['R-TYPE'][instruction_name]['funct']

            if(instruction_name  == 'SLL' or instruction_name == 'SRL' or instruction_name == 'SRA'):
            #se convierte cada operando a string binario
                rd = "{:05b}".format(int(operands[0]))
                rt = "{:05b}".format(int(operands[1]))
                sa = "{:05b}".format(int(operands[2]))
                instruction_bin = op_code + shamt + rt + rd + sa + function
            elif(instruction_name  == 'SLLV' or instruction_name  == 'SRLV' or instruction_name  == 'SRAV' ):
                rd = "{:05b}".format(int(operands[0]))
                rt = "{:05b}".format(int(operands[1]))
                rs = "{:05b}".format(int(operands[2]))
                instruction_bin = op_code + rs + rt + rd + shamt + function
            else:
                rd = "{:05b}".format(int(operands[0]))
                rs = "{:05b}".format(int(operands[1]))
                rt = "{:05b}".format(int(operands[2]))
                instruction_bin = op_code + rs + rt + rd + shamt + function

        elif(instruction_name in INSTRUCTIONS['I-TYPE']['MEMORY'].keys()):
            op_code = INSTRUCTIONS['I-TYPE']['MEMORY'][instruction_name]['opcode']

            rt= "{:05b}".format(int(operands[0]))
            #el seg operando es el formato offset(base), se obtiene el valor de cada uno
            offset_base = operands[1].replace("("," ").replace(")",'').split()
            #print(offset_base)
            offset = "{:016b}".format(int(offset_base[0]) & 0xffff) #para soportar numeros negativos, en complemento a 2
            #print(offset)
            base = "{:05b}".format(int(offset_base[1]))

            instruction_bin = op_code + base + rt + offset
        
        elif(instruction_name in INSTRUCTIONS['I-TYPE']['INMEDIATE'].keys()):
            #print(instruction_name)
            op_code = INSTRUCTIONS['I-TYPE']['INMEDIATE'][instruction_name]['opcode']
            #print(operands)
            if(instruction_name == 'BEQ' or instruction_name == 'BNE'):
                rs= "{:05b}".format(int(operands[0]))
                rt= "{:05b}".format(int(operands[1]))
            elif(instruction_name == 'LUI'):
                rt= "{:05b}".format(int(operands[0]))
            else:
                rt= "{:05b}".format(int(operands[0]))
                rs= "{:05b}".format(int(operands[1]))

            #para el caso de BNE o BEQ el offset puede ser un label
            try:
                if(instruction_name == 'LUI'):
                    inmediate = "{:016b}".format(int(operands[1]) & 0xffff)
                else:
                    inmediate = "{:016b}".format(int(operands[2]) & 0xffff) 
            except ValueError: #el index esta especificao con un label y no con un valor
                dif = labels[operands[2]] - input_lines_list.index(line) -1
                #print(dif)
                inmediate = "{:016b}".format(dif & 0xffff)
                #print(inmediate)

            if(instruction_name == 'LUI'):
                instruction_bin = op_code + "00000" + rt + inmediate
            else:
                instruction_bin = op_code + rs + rt + inmediate
        
        elif(instruction_name in INSTRUCTIONS['I-TYPE']['INST_INDEX'].keys()):
            op_code = INSTRUCTIONS['I-TYPE']['INST_INDEX'][instruction_name]['opcode']
            try:
                instr_index = "{:026b}".format(int(operands[0]))
            except ValueError: #el index esta especificao con un label y no con un valor
                instr_index = "{:026b}".format(labels[operands[0]])
            #print(instr_index)
            instruction_bin = op_code + instr_index

        elif(instruction_name in INSTRUCTIONS['J-TYPE'].keys()):
            op_code = "000000"
            function = INSTRUCTIONS['J-TYPE'][instruction_name]['funct']

            if(instruction_name == 'JR'):
                rs= "{:05b}".format(int(operands[0]))
                zeros_15 = "000000000000000"
                instruction_bin = op_code + rs + zeros_15 + function
            
            elif (instruction_name == 'JALR'):
                if(len(operands)==1): #rd+31 implicito
                    rs= "{:05b}".format(int(operands[0]))
                    rd = "{:05b}".format(31)
                else:
                    rd = "{:05b}".format(int(operands[0]))
                    rs= "{:05b}".format(int(operands[1]))
                zeros_5 = "00000"
                instruction_bin = op_code + rs + zeros_5 + rd + zeros_5 + function
        elif(instruction_name == "halt" or instruction_name == "HALT" ):
            instruction_bin = "11111111111111111111111111111111"
        else:
            #nop
            instruction_bin = "10101010101010101010101010101010"


        instruction_hexa = "{:08x}".format(int(instruction_bin,2))

        output_lines_bin.append(instruction_bin)
        output_lines_hexa.append(instruction_hexa)
        
        bin_bytes.append(int(instruction_bin[0:8],2))
        bin_bytes.append(int(instruction_bin[8:16],2))
        bin_bytes.append(int(instruction_bin[16:24],2))
        bin_bytes.append(int(instruction_bin[24:32],2))    

    output_file = open(output_file_path_hexa_txt,'w')
    for line in output_lines_hexa:
        output_file.write(line)
        output_file.write("\n")
    output_file = open(output_file_path_bin_txt,'w')
    for line in output_lines_bin:
        output_file.write(line)
        output_file.write("\n")
    
    #print(bin_bytes)
    bin_bytes_array = bytearray(bin_bytes)
    output_file_bin = open(output_file_path_bin,'wb')
    output_file_bin.write(bin_bytes_array)