//
//  SceneData.m
//  PusherGame
//
//  Created by Camilo Monteagudo on 27/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "SceneData.h"
#import "GlobalData.h"
#import "PathData.h"

SceneData* Scene;                 // Variable global, tener acceso a la escena actual desde cualquier lugar de la aplicacción

//=========================================================================================================================================
// Clase para mantener y manejar los datos necesarios para dibujar una escena
@implementation SceneBasicData
@synthesize zCell, Width, Height, xOff, yOff, Cols, Rows;
@synthesize ImgFondo, Pusher,Blocks;

//-----------------------------------------------------------------------------------------------------------------------------------------
// Funciones para conversión de coordenadaa
-(CGFloat) XCol: (int) col { return xOff + col * zCell;}                // Posicion horizontal en pixeles de la colunma 'col'
-(CGFloat) YRow: (int) row { return yOff + row * zCell;}                // Posicion vertical en pixeles de la fila 'row' 
-(CGFloat) XMCol:(int) col { return xOff + col * zCell + zCell/2;}      // Posicion media horizontal en pixeles de la colunma 'col'
-(CGFloat) YMRow:(int) row { return yOff + row * zCell + zCell/2;}      // Posicion media vertical en pixeles de la fila 'row' 
-(int)     ColX:(double) x { return (int)((x - xOff) / zCell); }        // Columna de de la posición x en pixeles
-(int)     RowY:(double) y { return (int)((y - yOff) / zCell); }        // Fila de de la posición y en pixeles

-(int)     DistCels:(double) pnts { return (int)(pnts/zCell); }         // Número de celdas que caben en una cantidad de puntos
-(CGFloat) DistPnts:(int)    cels { return cels * zCell;}               // Distancia en pixeles que ocupan una cantidad de celdas

//-----------------------------------------------------------------------------------------------------------------------------------------
// Abre un fichero de escena y retorna un diccionarios con los datos, si no se puede abir retorna NIL
+ (NSDictionary *)OpenSceneFile: (NSString*) fName 
  { 
  NSData* PList = [[NSFileManager defaultManager] contentsAtPath:fName ];         // Lee contenido de la escena
  
  NSString *sErr = nil;
  NSPropertyListFormat format;
  
  NSDictionary *Data = (NSDictionary *)[ NSPropertyListSerialization              // Serializa los datos de la escena
                                        propertyListFromData: PList
                                        mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                        format: &format
                                        errorDescription: &sErr];
  
  if(!Data || ![Data isKindOfClass:[NSDictionary class]])                         // Verifica si los datos son los adecuados
    {
    // NSLog(@"Error reading dictionary scene file: %@", sErr );
    return nil;
    }
  
  return Data;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Carga una escena con el numero de la escena en lista de escenas de la aplicación
+(SceneBasicData*) LoadNum:(int) Num
  {
  if( AppData==nil || Num<0 || Num>=AppData.nScenes )
    return nil;
  
  return [SceneBasicData LoadName: [AppData PathAt:Num] ];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Carga una escena con el nombre suministrado
+(SceneBasicData*) LoadName:(NSString*) fName
  {
  NSDictionary *Data = [SceneBasicData OpenSceneFile:fName ];           // Lee y parsea el fichero de la escena
  if(!Data ) return FALSE;                                              // Verifica si se pudo leer bien
  
  SceneBasicData *scnData = [SceneBasicData new];                       // Crea un objeto para los datos basicos de la escena
  if( ![scnData ReadData:Data] ) return nil;                            // Lee los datos basicos de la escena
    
  return scnData;                                                       // Retorna el objeto con los datos basicos
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Lee todos los datos basicos de la escena
-(BOOL) ReadData: (NSDictionary*) Data
  {
  Blocks   = [NSMutableArray array];                                    // Crea un arreglo vacio para los bloques de la escena
  
  ImgFondo = [Data objectForKey:@"ImgFondo" ];                          // Obtiene nombre de la imagen de fondo
  
  NSNumber *Size   = [Data  objectForKey:@"CellSize" ];                 // Obtiene el tamaño de las celdas
  NSNumber *Ancho  = [Data  objectForKey:@"Width"    ];                 // Obtiene el ancho de la zona de juego
  NSNumber *Alto   = [Data  objectForKey:@"Height"   ];                 // Obtiene el alto de la zona de juego
  NSNumber *sCols  = [Data  objectForKey:@"Cols"     ];                 // Obtiene la cantidad de columnas de la escena
  NSNumber *sRows  = [Data  objectForKey:@"Rows"     ];                 // Obtiene la cantidad de filas de la escena

  zCell  = Size.intValue /2;                                            // Pone los valores en la escena actual
  Width  = Ancho.intValue/2;
  Height = Alto.intValue /2;
  Cols   = sCols.intValue;
  Rows   = sRows.intValue;
  
  xOff = (Width - (Cols*zCell) ) / 2;                                   // Calcula el desplazamiento de la escena
  yOff = (Height- (Rows*zCell) ) / 2;
  
  if( ![self ReadBlocksForData:Data] ) return FALSE;                    // Lee información de los bloques de los datos de la escena
  if( ![self ReadPusherForData:Data] ) return FALSE;                    // Lee información del pusher de los datos de la escena
  
  return TRUE;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Calcula el desplazamiento del origen de coodenadas de la escena
-(void) OffsetsView:(UIView*) Zone
  {
  CGSize sz = Zone.bounds.size;

  xOff = (Width - (Cols*zCell) ) / 2;                                   // Calcula el desplazamiento en la escena
  yOff = (Height- (Rows*zCell) ) / 2;

  xOff += ((sz.width - Scene.Width  ) / 2);                             // Calcuña desplazamiento de la escena en la vista
  yOff += ((sz.height- Scene.Height ) / 2);
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Inicializa el pusher, desde los datos del fichero de escena
-(BOOL) ReadPusherForData: (NSDictionary*) Data
  { 
  NSString *sPusher = [Data objectForKey:@"Pusher" ];
  if( sPusher==nil ) return FALSE;

  Pusher = [PusherData FromString:sPusher];
  return TRUE;  
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Inicializa los bloques de la escena desde los datos del fichero de definición de escena
-(BOOL) ReadBlocksForData: (NSDictionary*) Data
  { 
  NSArray *bData = [Data  objectForKey:@"Blocks" ];
  if( bData==nil ) return FALSE;
      
  for( NSString *sBlock in bData )
    {
    BlockData* Block = [BlockData FromString:sBlock];
    
    [Blocks addObject:Block];
    }
    
  return TRUE;  
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Dibuja la scena 'idx' dentro del rectangulo 'rc' en el contexto ct
+(BOOL) DrawInContext: (CGContextRef) ct Rect:(CGRect) rc Scene:(int) idx
  { 
  SceneBasicData * sn = [SceneBasicData LoadNum: idx];                // Carga datos básico de la escena desde fichero
  if( sn == nil ) return FALSE;                                       // No los pudo cargar, termina
    
  [SceneBasicData DrawImage:sn.ImgFondo AtRect:rc];                   // Dibuja el fondo de la escena
        
  sn.xOff += rc.origin.x;                                             // Pone origen de la escena a esquina superior-derecha del rectangulo
  sn.yOff += rc.origin.y;
        
  for( BlockData* bck in sn.Blocks )                                  // Recorre todo los bloques
    {
    float xPos = [sn XCol: bck.Col];                                  // Determina posicion del bloque
    float yPos = [sn YRow: bck.Row];
        
    rc = CGRectMake(xPos, yPos, sn.zCell, sn.zCell );                 // Calcula rectangulo para dibujar el bloque
    [self DrawCacheImage:bck.Name AtRect:rc];                         // Dibuja el bloque en el rectangulo
    }

  CGContextSaveGState(ct);                                            // Guarda estado del contecto de dibujo
    
  float xPos = [sn XMCol: sn.Pusher.Col];                             // Calcula posición del centro del pusher
  float yPos = [sn YMRow: sn.Pusher.Row];
        
  CGContextTranslateCTM(ct, xPos , yPos );                            // Traslada centro de coordenadas al centro del puscher
  CGContextRotateCTM(ct, sn.Pusher.Angle );                           // Rota el pusher al angulo dado
  
  rc = CGRectMake( -sn.zCell/2, -sn.zCell/2, sn.zCell, sn.zCell );    // Calcula rectangulo del pusher en nuevi systema de coordenadas
        
  [self DrawCacheImage:sn.Pusher.Name AtRect:rc];                     // Dibuja imagen del pusher en el rectangulo
    
  CGContextRestoreGState(ct);                                         // Restaura estado de conteto de dibujo
  
  return TRUE;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Carga la imagen con nombre 'sImage' y la dibuaja en el rectangulo 'rc' (La imagen no se guarda en el cache)
+ (void) DrawImage: (NSString*) sImage AtRect:(CGRect) rc
  {
  NSString *pImg = [AppData GetFullPath:sImage];                      // Obtiene el camino completo a la image de fondo de la escena
    
  UIImage* imgScene = [UIImage imageWithContentsOfFile:pImg];         // Carga imagen desde fichero (Sin cache)
  if( imgScene == nil ) return;                                       // No la pudo cargar
  
  [imgScene drawInRect: rc];                                          // La dibuja en la zona de juego
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Carga la imagen con nombre 'sImage' y la dibuaja en el rectangulo 'rc' (La imagen se guarda en el cache)
+ (void) DrawCacheImage: (NSString*) sImage AtRect:(CGRect) rc
  {
  UIImage* imgScene = [UIImage imageNamed:sImage];                      // Carga imagen desde fichero
  if( imgScene == nil ) return;                                       // No la pudo cargar
  
  [imgScene drawInRect: rc];                                          // La dibuja en la zona de juego
  }

//---------------------------------------------------------------------------------------------------------------------------------------------

@end

//=========================================================================================================================================
@interface SceneData()
@end

//=========================================================================================================================================
@implementation SceneData
@synthesize Moves, ImgFill, GameZone, FileName;

Byte Cells[GRID_XSIZE][GRID_YSIZE];                                     // Matriz con información de cada celda de la escena

//-----------------------------------------------------------------------------------------------------------------------------------------
// Carga una escena con el nombre suministrado
+(BOOL) LoadName:(NSString*) fName Game:(UIView*) Zone Push:(UIImageView*) push
  {
  if( Scene!=nil && Scene.GameZone == Zone )                            // Ya habia una escena cargada, para la vista
    {
    for( BlockData *Bck in Scene.Blocks )                               // Quita bloques de la escena anterior de la vista
      [Bck.Ctl removeFromSuperview];
    }
  
  NSDictionary *Data = [SceneData OpenSceneFile:fName ];                // Lee y parsea el fichero de la escena
  if(!Data )
    return FALSE;                                                       // Verifica si se pudo leer bien
  
  Scene = [SceneData alloc];                                            // Crea objeto para datos de escena vacio
  if( ![Scene ReadData:Data] ) return FALSE;                            // Lee los datos basicos de la escena
  
  Scene.FileName = fName;                                               // Guarda nombre de la escena cargada
  Scene.GameZone = Zone;                                                // Asocia View de la zona de juego a la escena
  
  Scene.ImgFill   = [Data objectForKey:@"ImgFill" ];                    // Obtiene nombre de la imagen para relleno de la escena
  NSNumber *Moves = [Data objectForKey:@"Moves"   ];                    // Obtiene cantidad de movimientos de la solución
  Scene.Moves     = Moves.intValue;
  
  [Scene OffsetsView:Zone];                                             // Determina el desplazamiento de origen de la escena
  
  if( ![Scene ReadGridForData:Data]   ) return FALSE;                   // Lee información de las celdas de los datos de la escena
  
  [Scene.Pusher AssociteView:push];                                     // Asocia el ImageView con objeto pusher
  
  for( int i=0; i<Scene.Blocks.count; ++i )                             // Recorre todos los bloques
    {
    BlockData* blk = Scene.Blocks[i];                                   // Toma el bloque actual
    
    [blk AddToGame:Zone At:i ];                                         // Adiciona el bloque a la vista del juego y los asocia a la escena
    }
    
  return TRUE;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Carga una escena con el numero de la escena en lista de escenas de la aplicación
+(BOOL) LoadNum:(int) Num Game:(UIView*) gZone Push:(UIImageView*) push;
  {
  if( AppData==nil || Num<0 || Num>=AppData.nScenes )
    return FALSE;
  
  return [SceneData LoadName: [AppData PathAt:Num] Game:gZone Push:push ];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Carga una escena con el nombre suministrado
-(BOOL) LoadSolution
  {
  NSDictionary *Data = [SceneData OpenSceneFile:FileName ];                   // Lee y parsea el fichero de la escena
  if(!Data ) return FALSE;                                                    // Verifica si se pudo leer bien
 
  NSArray *sData = [Data  objectForKey:@"Solution" ];                         // Cargo la llave con los datos de la solución
  if( sData==nil ) return FALSE;                                              // Si no hay solución, retorna falso
    
  [PathData Start];
  int lstCol=-1, lstRow=-1;
  for( NSString *sPathPnt in sData )
    {
    PathPnt* Pnt = [PathPnt FromString:sPathPnt];                             // Obtiene un punto de los datos en la cadena
    if( Pnt==nil ) return FALSE; 
    
    if( lstCol!= -1 )                                                         // El primero se lo salta (coge donde esta el pusher)
      {
      if( lstRow == Pnt.Row )                                                 // Esta en la misma columna del punto anterior
        {
        Pnt.Sent = Horz;                                                      // Sentido horizontal
        Pnt.Sgn  = (lstCol<Pnt.Col)? 1 : -1;                                  // Hacia la derecha positivo, al izquierda negativo
        }
      else                                                                    // Asume que debe estar en la misma fila
        {
        Pnt.Sent = Vert;                                                      // Sentido vertical
        Pnt.Sgn  = (lstRow<Pnt.Row)? 1 : -1;                                  // Hacia abajo positivo, hacia arriba negativo
        }
        
      [Path AddPathPnt:Pnt ];                                                 // Adiciona el punto al camino
      }
    
    lstCol = Pnt.Col;                                                         // Almacena la ultima fila/columna analizada
    lstRow = Pnt.Row;
    }
    
  return TRUE; 
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Inicializa todas las celdas de la escena desde los datos del fichero de escena
-(BOOL) ReadGridForData: (NSDictionary*) Data
  { 
  NSArray *gData = [Data  objectForKey:@"Grid" ];
  if( gData==nil ) return FALSE;

  int MinCols=0, row=0, hexNum;
  for( NSString *sRow in gData )
    {
    NSArray *sCols = [ sRow componentsSeparatedByString:@"," ];
  
    int col = 0;
    for( NSString *sCol in sCols )
      {
      sscanf( sCol.UTF8String, "%Xd", &hexNum);  
    
      Cells[row][col] = (Byte)hexNum;
    
      ++col;
      }
  
    ++row;
  
    if( MinCols==0 || MinCols<col ) MinCols = col;
    }

  return TRUE;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Inicializa los bloques de la escena desde los datos del fichero de definición de escena
//-(BOOL) ReadColorForData: (NSDictionary*) Data
//  { 
//  NSString *ColBck = [Data objectForKey:@"ColFondo" ];                            // Obtiene el color especificado
//  if( ColBck == nil ) return false;
//  
//  int redCol, greenCol, blueCol;
//  
//  int ret = sscanf( ColBck.UTF8String, "%2X%2X%2X", &redCol, &greenCol, &blueCol );
//  if( ret != 3 ) return false;
//  
//  float fRed   = redCol  /255.0;
//  float fGreen = greenCol/255.0;
//  float fBlue  = blueCol /255.0;
//  
//  Scene.ColFondo = [UIColor colorWithRed:fRed green:fGreen blue:fBlue alpha:1.0 ];
//  return true;
//  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el bloque que se encuetra en col, row de la escena
-(BlockData*) BlockInCol:(int) col Row:(int) row
  { 
  Byte val = [self GetValCol:col Row:row];
  int  idx = GetValInfo( val );
  
  if( GetValTipo(val) != cBloque || idx<0 || idx>=super.Blocks.count )
    return nil;
  
  return super.Blocks[idx];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Analiza si todos los bloques de la escena estan sobre u target correcto para el
-(BOOL) AllBlockInTarget
  {
  for( BlockData *Bck in super.Blocks )
    {
    if( Bck.Id>=12 ) continue;
    
    if( ![Bck InTarget] ) return FALSE;
    }
    
  return TRUE;  
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Funciones para manejar los bloques
-(int) nBlocks                  { return (int)super.Blocks.count;   }
-(BlockData *) BlockAt:(int)Idx { return super.Blocks[Idx]; }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Funciones para manejar el contenido de las celdas
-(BOOL) IsParedCol:(int) col Row:(int) row  { return IsValPared( Cells[row][col] ); }
-(BOOL) IsPisoCol: (int) col Row:(int) row  { return IsValPiso(  Cells[row][col] ); }
-(BOOL) IsBlockCol:(int) col Row:(int) row  { return IsValBlock( Cells[row][col] ); }
-(BOOL) IsTagetCol:(int) col Row:(int) row  { return IsValTaget( Cells[row][col] ); }

-(Byte) GetValCol: (int) col Row:(int) row  { return Cells[row][col]; } 
-(Byte) GetTipoCol:(int) col Row:(int) row  { return GetValTipo( Cells[row][col] ); }
-(Byte) GetInfoCol:(int) col Row:(int) row  { return GetValInfo( Cells[row][col] ); }

-(void) SetVal: (Byte) val Col:(int) col Row:(int) row  { Cells[row][col]=val; }
//-(void) SetInfo:(Byte) inf Col:(int) col Row:(int) row  { SetValInfo( Cells[row][col], inf ); }

//-----------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================
