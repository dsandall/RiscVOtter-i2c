# I2C Test Program v2
# Dylan Sandall
# December 8, 2022
# PSEUDOCODE
	# (write)
	# set MOSI
	# set slave addr
	# clr RW
	# set new message flag
	# 
	# loop: check new message flag
	#  	goto loop if high
	#   break if low
	#
	# (read)
	# slave addr already set
	# set RW
	# set new message
	#
	# loop: check new message flag
	#	goto loop if high
	#   break if low
	# read MISO

BEGIN:
#initialize addresses and constants
    li x10, 0x11ff00a0 #slave addr (MMIO addr for slave addr) 
    li x11, 0x11ff00b0 #flag addr
    li x3, 0x11ff0000 #MOSI addr
    li x4, 0x11ff0010 #MISO addr
    li x22, 2 #new msg, write 
    
#initiate slave address register
    li x5, 0x27 #slave device addr 0100111
    sb x5, 0(x10) #store addr in slaveaddr
	
#begin transmission    
    li x5, 0x8 
    call sendbyte    
	li x5, 0x4 
    call sendbyte
    li x5, 0x2 
    call sendbyte
	li x5, 0x1 
    call sendbyte

#celebration NOPs
	done:
	nop
	nop
	nop
	j done

    
sendbyte:
	#sends data byte from x5, sets appropriate flag, and waits for completion
    #inputs- x5
    #constants- x3, x22, x11
    #tweaks- x6
    sb x5, 0(x3) #store data in MOSI
	sb x22, 0(x11) #store new write in flags
	waitloop:
    lb x6, 0(x11) #read flags
    andi x6, x6, 2 #disable bits that are not newmsg flag
    bne x0, x6, waitloop #loop until newmsg clear
    #byte transmission complete
    ret