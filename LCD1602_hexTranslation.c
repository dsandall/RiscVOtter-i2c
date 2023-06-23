#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>

#define BACKLIGHT 8
#define DATA 1
static int iBackLight = BACKLIGHT;

static void WriteCommand(unsigned char ucCMD)
{
unsigned char uc;

	uc = (ucCMD & 0xf0) | iBackLight; // most significant nibble sent first
		printf("%X\n", uc);
		//usleep(PULSE_PERIOD); // manually pulse the clock line

	uc |= 4; // enable pulse
		printf("%X\n", uc);
		//usleep(PULSE_PERIOD);
    
	uc &= ~4; // toggle pulse
		printf("%X\n", uc);
		//usleep(CMD_PERIOD);
    printf("\n");

	uc = iBackLight | (ucCMD << 4); // least significant nibble
		printf("%X\n", uc);
		//usleep(PULSE_PERIOD);

	uc |= 4; // enable pulse
		printf("%X\n", uc);
		//usleep(PULSE_PERIOD);

	uc &= ~4; // toggle pulse
		printf("%X\n", uc);
		//usleep(CMD_PERIOD);

} /* WriteCommand() */

void lcd1602WriteString(char *text)
{
unsigned char ucTemp[2];
int i = 0;
	while (i<16 && *text)
	{
		ucTemp[0] = iBackLight | DATA | (*text & 0xf0);
		//write(file_i2c, ucTemp, 1);
    printf("%X\n", ucTemp[0]);

		ucTemp[0] |= 4; // pulse E
		//write(file_i2c, ucTemp, 1);
    printf("%X\n", ucTemp[0]);
    

		ucTemp[0] &= ~4;
		//write(file_i2c, ucTemp, 1);
    printf("%X\n", ucTemp[0]);


		ucTemp[0] = iBackLight | DATA | (*text << 4);
		//write(file_i2c, ucTemp, 1);
    printf("%X\n", ucTemp[0]);

		ucTemp[0] |= 4; // pulse E
    //write(file_i2c, ucTemp, 1);
    printf("%X\n", ucTemp[0]);

    ucTemp[0] &= ~4;
    //write(file_i2c, ucTemp, 1);
    //usleep(CMD_PERIOD);
    printf("\n");

		text++;
		i++;
	}
} /* WriteString() */

void main()
{
	WriteCommand(0x02); // Set 4-bit mode of the LCD controller
	WriteCommand(0x28); // 2 lines, 5x8 dot matrix
	WriteCommand(0x0c); // display on, cursor off
	WriteCommand(0x06); // inc cursor to right when writing and don't scroll
	WriteCommand(0x80); // set cursor to row 1, column 1
    WriteCommand(0x0E); // clear the screen

  	lcd1602WriteString("A");
}

