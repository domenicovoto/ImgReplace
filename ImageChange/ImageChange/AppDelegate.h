//
//  AppDelegate.h
//  ImageChange
//
//  Created by Domenico on 02/10/13.
//  Copyright (c) 2013 Domenico Voto. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    NSURL *sorgenteURL;
    NSURL *destinazioneURL;
    
    BOOL selectedSorg;
    BOOL selectedDest;
    
    BOOL operazioneCompletata;
}

- (IBAction)sorgenteAction:(id)sender;
- (IBAction)destinazioneAction:(id)sender;

- (IBAction)checkBoxPrefixAction:(id)sender;
- (IBAction)checkBoxRetinaAction:(id)sender;

- (IBAction)sostituisciButtonAction:(id)sender;

@property (assign) IBOutlet NSWindow *window;

//oggetti
@property (weak) IBOutlet NSTextField *sorgenteLbl;
@property (weak) IBOutlet NSTextField *destinazioneLbl;

@property (weak) IBOutlet NSButton *checkBoxPrefix;
@property (weak) IBOutlet NSTextField *prefixTxt;

@property (weak) IBOutlet NSButton *checkBoxRetina;
@property (weak) IBOutlet NSTextField *retinaTxt;

@property (weak) IBOutlet NSButton *sostituisciBtn;
@property (weak) IBOutlet NSTextField *statusLbl;
@end
