//
//  main.m
//  compiler
//
//  Created by Moises Anthony Aranas on 2/18/16.
//  Copyright © 2016 Moises Anthony Aranas. All rights reserved.
//

#import <Foundation/Foundation.h>

// constants
const NSString* TAB = @"\t";
NSCharacterSet* kAlphaCharacterSet;
NSCharacterSet* kDecimalCharacterSet;
NSCharacterSet* kAddOpCharacterSet;
NSCharacterSet* kMultiplyOpCharacterSet;

// variables
NSString *lookAheadCharacter;

/**
 @brief Read character from input
 */
void getChar()
{
    unichar inputChar = getchar();
    lookAheadCharacter = [NSString stringWithFormat:@"%C", inputChar];
}

/**
 @brief Report error
 */
void error(NSString* string)
{
    NSLog(@"ERROR: %@", string);
}

/**
 @brief Report error and halt
 */
void errorAndAbort(NSString* string)
{
    error(string);
    exit(0);
}

/**
 @brief Report what was expected
 */
void expected(NSString* string)
{
    errorAndAbort([NSString stringWithFormat:@"Expected %@", string]);
}

/**
 @brief Match a specific input character
 */
void match(NSString* ch)
{
    if ([lookAheadCharacter isEqualToString:ch])
    {
        getChar();
    }
    else
    {
        expected([NSString stringWithFormat:@"%@", ch]);
    }
}

/**
 @brief Recognize an Alpha Character
 */
BOOL isAlpha(NSString* ch)
{
    return [kAlphaCharacterSet
            characterIsMember:[[ch uppercaseString] characterAtIndex:0]];
}

/**
 @brief Recognize a Decimal Digit
 */
BOOL iSDigit(NSString* ch)
{
    return [kDecimalCharacterSet
            characterIsMember:[[ch uppercaseString] characterAtIndex:0]];
}

/**
 @brief Get an identifier
 */
NSString* getName()
{
    if (!isAlpha(lookAheadCharacter))
    {
        expected(@"Name");
    }
    NSString* ret = [lookAheadCharacter uppercaseString];
    getChar();
    return ret;
}

/**
 @brief Get a number
 */
NSString* getNum()
{
    if (!iSDigit(lookAheadCharacter))
    {
        expected(@"Integer");
    }
    NSString* ret = lookAheadCharacter;
    getChar();
    return ret;
}

/**
 @brief Output a string with tab
 */
void emit(NSString* string)
{
    NSString *text = [NSString stringWithFormat:@"%@%@", TAB, string];
    printf("%s",[text cStringUsingEncoding:NSUTF8StringEncoding]);
}

/**
 @brief Output a string with tab and CRLF
*/
void emitLn(NSString* string)
{
    NSLog(@"%@%@", TAB, string);
}

/**
 @brief Parse and translate a math factor
 */
void expression(); // forward declaration
void factor()
{
    if ([lookAheadCharacter isEqualToString:@"("])
    {
        match(@"(");
        expression();
        match(@")");
    }
    else
    {
        emitLn([NSString stringWithFormat:@"mov eax, %@", getNum()]);
    }
}

/**
 @brief Recognize and Translate a multiply
 */
void multiply()
{
    match(@"*");
    factor();
    emitLn(@"pop ebx");
    emitLn(@"mul ebx");
}

/**
 @brief Recognize and translate a divide
 */
void divide()
{
    match(@"/");
    factor();
    emitLn(@"pop ebx");
    emitLn(@"div ebx");
}

/**
 @brief Parse term
 */
void term()
{
    factor();
    while ([kMultiplyOpCharacterSet characterIsMember:[lookAheadCharacter characterAtIndex:0]]) {
        emitLn(@"push eax");
        if ([lookAheadCharacter isEqualToString:@"*"])
        {
            multiply();
        }
        else if ([lookAheadCharacter isEqualToString:@"/"])
        {
            divide();
        }
        else
        {
            expected(@"Mulop");
        }
    }

}

/**
 @brief Recognise and translate add
 */
void add()
{
    match(@"+");
    term();
    emitLn(@"pop ebx");
    emitLn(@"add eax, ebx");
}

/**
 @brief Recognise and translate subtract
 */
void subtract()
{
    match(@"-");
    term();
    emitLn(@"pop ebx");
    emitLn(@"sub eax,ebx");
    emitLn(@"neg eax");
}

BOOL isAddOp(NSString *ch)
{
    return [kAddOpCharacterSet characterIsMember:[ch characterAtIndex:0]];
}

/**
 @brief Parse and translate a math expression
 */
void expression()
{
    if (isAddOp(lookAheadCharacter))
    {
        emitLn(@"mov eax, 0");
    }
    else
    {
        term();
    }
    while ([kAddOpCharacterSet characterIsMember:[lookAheadCharacter characterAtIndex:0]])
    {
        emitLn(@"push eax");
        if ([lookAheadCharacter isEqualToString:@"+"])
        {
            add();
        }
        else if ([lookAheadCharacter isEqualToString:@"-"])
        {
            subtract();
        }
        else
        {
            expected(@"Addop");
        }
    }
}

/**
 @brief Initialize
 */
void init()
{
    getChar();
}

/**
 @brief Main function
 */
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        kAlphaCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        kDecimalCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
        kAddOpCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
        kMultiplyOpCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"*/"];
        init();
        expression();
    }
    return 0;
}
