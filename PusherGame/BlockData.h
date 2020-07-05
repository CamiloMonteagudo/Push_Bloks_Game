//
//  BlockData.h
//  PusherGame
//
//  Created by Camilo Monteagudo on 29/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <Foundation/Foundation.h>

//=========================================================================================================================================
@interface BlockData : NSObject

@property Byte Tipo;                                    // Tipo de bloque  (por ahora solo soporta uno)
@property int  Row;                                     // Fila donde esta el bloque
@property int  Col;                                     // Columna donde esta el bloque
@property int  Id;                                      // Identificador del bloque (debe corresponder con el del target donde se puede ubicar)
@property Byte On;                                      // Contenido que tenia la celda sobre la que esta el bloque

@property (copy, nonatomic) NSString *Name;
@property (weak, nonatomic) UIImageView *Ctl;           // Control para representar el bloque en pantalla

+(BlockData*) FromString:(NSString*) sData;

-(void) AddToGame:(UIView*) Zone At:(int) idx;
-(void) MoveCol:(int) col Row:(int) row;
-(BOOL) InTarget;

@end

//=========================================================================================================================================
