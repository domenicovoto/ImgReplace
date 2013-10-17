//
//  AppDelegate.m
//  ImageChange
//
//  Created by Domenico on 02/10/13.
//  Copyright (c) 2013 Domenico Voto. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    selectedSorg = NO;
    selectedDest = NO;
    
    operazioneCompletata = NO;
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application{
    return YES;
}

- (void)checkOperazione{
    if (operazioneCompletata) {
        [self.statusLbl setHidden:YES];
        [self.sostituisciBtn setEnabled:YES];
        
        selectedSorg = NO;
        selectedDest = NO;
        
        [self.checkBoxPrefix setState:NSOffState];
        [self.prefixTxt setHidden:YES];
        
        
        sorgenteURL = nil;
        destinazioneURL = nil;
        
        self.sorgenteLbl.stringValue = @"";
        self.destinazioneLbl.stringValue = @"";
        
        operazioneCompletata = NO;
    }
}

#pragma mark - Combo
- (IBAction)sorgenteAction:(id)sender {
    [self checkOperazione];
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    
    // display the panel
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            
            // grab a reference to what has been selected
            sorgenteURL = [[openPanel URLs] objectAtIndex:0];
            
            // write our file name to a label
            NSString *theString = [NSString stringWithFormat:@"%@", sorgenteURL];
            self.sorgenteLbl.stringValue = theString;
            selectedSorg = YES;
            
            if (selectedDest == YES) {
                [self.sostituisciBtn setEnabled:YES];
            }
        }
    }];
}

- (IBAction)destinazioneAction:(id)sender {
    [self checkOperazione];
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    
    // display the panel
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            
            // grab a reference to what has been selected
            destinazioneURL = [[openPanel URLs] objectAtIndex:0];
            
            // write our file name to a label
            NSString *theString = [NSString stringWithFormat:@"%@", destinazioneURL];
            self.destinazioneLbl.stringValue = theString;
            selectedDest = YES;
            
            if (selectedSorg == YES) {
                [self.sostituisciBtn setEnabled:YES];
            }
        }
    }];
}

- (IBAction)checkBoxPrefixAction:(id)sender {
    NSLog(@"check prefix action");
    
    if ([self.checkBoxPrefix state] == NSOnState) {
        [self.prefixTxt setHidden:NO];
    }
    else if ([self.checkBoxPrefix state] == NSOffState){
        [self.prefixTxt setHidden:YES];
    }
}

- (IBAction)checkBoxRetinaAction:(id)sender {
    NSLog(@"check retina action");
    
    if ([self.checkBoxRetina state] == NSOnState) {
        [self.retinaTxt setHidden:NO];
    }
    else if ([self.checkBoxPrefix state] == NSOffState){
        [self.retinaTxt setHidden:YES];
    }
}

- (IBAction)sostituisciButtonAction:(id)sender {
    NSLog(@"sostituisci action");
    [self.sostituisciBtn setEnabled:NO];
    
    NSError *erroreSorgente;
    NSArray *contentsSorgente = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:sorgenteURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&erroreSorgente];
    
    //retina sorgente
    NSString *lastPathSorgenteRetina = [sorgenteURL lastPathComponent];
    lastPathSorgenteRetina = [lastPathSorgenteRetina stringByAppendingString:self.retinaTxt.stringValue];
    NSURL *pathSorgenteRetina = [[sorgenteURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:lastPathSorgenteRetina];
    NSArray *contentsSorgenteRetina = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:pathSorgenteRetina includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&erroreSorgente];
    //retina sorgente
    
    //retina destinazione
    NSString *lastPathDestinazioneRetina = [destinazioneURL lastPathComponent];
    lastPathDestinazioneRetina = [lastPathDestinazioneRetina stringByAppendingString:self.retinaTxt.stringValue];
    NSURL *pathDestinazioneRetina = [[destinazioneURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:lastPathDestinazioneRetina];
    //retina destinazione
    
    //dobbiamo aggiungere il prefisso
    if (self.checkBoxPrefix.state == NSOnState) {
        [self aggiungiPrefisso:contentsSorgente];
        contentsSorgente = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:sorgenteURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&erroreSorgente];
        
        if ([self.checkBoxRetina state] == NSOnState) {
            [self aggiungiPrefisso:contentsSorgenteRetina];
            contentsSorgenteRetina = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:pathSorgenteRetina includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&erroreSorgente];
        }
    }
    
    //spostiamo i file
    [self spostaFile:contentsSorgente pathDestURL:destinazioneURL];
    
    if ([self.checkBoxRetina state] == NSOnState) {
        [self spostaFile:contentsSorgenteRetina pathDestURL:pathDestinazioneRetina];
    }
    
    [self.statusLbl setHidden:NO];
    operazioneCompletata = YES;
}

- (void)aggiungiPrefisso:(NSArray *)contenutoSorgente{
    for (NSURL *fileURL in contenutoSorgente) {
        NSString *filePath = [fileURL path];
        NSString *newFileName = [NSString stringWithFormat:@"%@%@", self.prefixTxt.stringValue, [fileURL lastPathComponent]];
        NSLog(@"newFileName:%@", newFileName);
        
        NSError *erroreRename;
        NSString *newPath = [[filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFileName];
        [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:newPath error:&erroreRename];
        
        NSLog(@"fileURL:%@\nnewPath:%@", filePath, newPath);
        
        if (erroreRename) {
            NSLog(@"errore rename:%@", [erroreRename localizedDescription]);
        }
    }
}

- (void)spostaFile:(NSArray *)contenutoSorgente pathDestURL:(NSURL *)pathURLDest{
    for (NSURL *fileURL in contenutoSorgente) {
        NSString *fileName = [fileURL lastPathComponent];
        
        NSString *destPath = [pathURLDest path];
        NSString *newPath = [destPath stringByAppendingPathComponent:fileName];
        NSError *erroreReplace;
        
        NSLog(@"newPath:%@", newPath);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:NO]) {
            NSError *erroreRemove;
            [[NSFileManager defaultManager] removeItemAtPath:newPath error:&erroreRemove];
            
            if (erroreRemove) {
                NSLog(@"errrore remove:%@", [erroreRemove localizedDescription]);
            }
            else{
                NSLog(@"file rimosso");
                [[NSFileManager defaultManager] moveItemAtPath:[fileURL path] toPath:newPath error:&erroreReplace];
                
                if (erroreReplace) {
                    NSLog(@"errrore replace:%@", [erroreReplace localizedDescription]);
                }
                else{
                    NSLog(@"file spostato");
                }
            }
        }
        else{
            NSLog(@"file non presente:%@", newPath);
        }
    }
}
@end
