//
//  main.c
//  exp4
//
//  Created by 徐永�?on 2018/5/3.
//  Copyright © 2018�?徐永�? All rights reserved.
//

#include <stdio.h>
#include <string.h>
#pragma inline
extern void FUNC3_4(void);
extern void FUNC3_5(void);
extern void FUNC3_6(void);
extern void search_good(void);
extern void modify_info(void);

int main(void) {
    // insert code here...
    char ch;
    int auth = 0;
    int inp = 0;
    int step = 0;
    int choice = 0;
    char owner[] = "chenjiajie";
    char password[] = "123456";
    char name[20];
    char psw[20];
    int close;
    asm push ax
    asm mov ax,1
    asm mov close,ax 
    asm pop ax


    while(close){
        inp = 0;
        step = 0;
        printf("Please enter your name:\n");
        name[inp] = getchar();
        if(name[inp]=='q')
            break;
        if(name[inp]=='\n')
            step = 1;
        if(step == 0){
            inp++;
            while(name[inp-1]!='\n'){
                name[inp] = getchar();
                inp++;
            }
            name[inp-1] = '\0';
            if(strcmp(owner, name)){
                printf("ERROR!\n");
                continue;
            }
            printf("Please enter your password:\n");
            scanf("%s", psw);
            ch = getchar();
            if(strcmp(psw, password)){
                printf("ERROR!\n");
                continue;
            }
            auth = 1;
        }
        if(auth==0){
            while (1) {
                printf("Guest:\n");
                printf("*********************************\n");
                printf("1.query info        2.exit\n");
                printf("*********************************\n");
                printf("please input choice between 1 and 2\n");
                scanf("%d", &choice);
                ch = getchar();
                if(choice<1||choice>2){
                    printf("ERROR!\n");
                    continue;
                }
                else if(choice == 2)
                    break;
                else{//功能1
                    printf("please input the good you wanna search!\n");
                }
            }
        }
        else{
            while (1) {
                printf("Host:\n");
                printf("*********************************\n");
                printf("1.query info        2.modify info\n");
                printf("3.calcu rate        4.rank rate\n");
                printf("5.output info       6.exit\n");
                printf("*********************************\n");
                printf("please input choice between 1 and 6\n");
                scanf("%d", &choice);
                ch = getchar();
                if(choice<1||choice>6){
                    printf("ERROR!\n");
                    continue;
                }
                else if(choice == 6)
                    break;
                else if(choice == 1){
                    search_good();
                }
                else if(choice == 2){
                     modify_info();
                }
                else if(choice == 3){
                    FUNC3_4();
                }
                else if(choice == 4){
                    FUNC3_5();
                }
                else if(choice == 5){
                    FUNC3_6();
                }
            }
        }
        
    }
    ch = '0';
    printf("Good Bye!\n");
    return 0;
}
