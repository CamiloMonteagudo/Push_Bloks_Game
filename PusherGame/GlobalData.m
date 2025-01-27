//
//  GlobalData.m
//  PusherGame
//
//  Created by Camilo Monteagudo on 18/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "GlobalData.h"
#import "SceneData.h"
#import "Sound.h"

GlobalData* AppData;
CronoTime*  SceneCrono;              // Variable global, para controlar el tiempo de juego por escena

//=========================================================================================================================================
// Objeto con los datos de cada escena
@interface DataScene : NSObject <NSCoding>

@property (nonatomic) NSString* Path;
@property (nonatomic) NSString* Fondo;

@property (nonatomic) int  Puntos;
@property (nonatomic) BOOL Lock;

@end


//=========================================================================================================================================
// Propiedades privadas de la clase GlobalData
@interface GlobalData ()

@property (nonatomic) NSMutableArray* Scenes;

@end
//=========================================================================================================================================

@implementation GlobalData
@synthesize Scenes, IdxScene, Zoom, Pages;
#ifdef FREE_TO_PLAY
  @synthesize PurchaseNoAds, PurchaseUnlock, PurchaseSolLavel1, PurchaseSolLavel2, PurchaseSolLavel3;
  @synthesize ProcessNoAds, ProcessUnlock, ProcessSolLavel1, ProcessSolLavel2, ProcessSolLavel3;
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el objeto global que mantiene los datos de la aplicación
+ (GlobalData *) Default
  {
  if( AppData == nil )                                                            // Si no se han cargado los datos de la aplicación
    AppData = [GlobalData Load];                                                  // Los carga
    
  return AppData;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el camino el fichero que guarda los datos de la aplicación
+ (NSString *) FileAppData
  {
  NSFileManager *fMng = [[NSFileManager alloc] init];                             // Crea objeto para manejo de ficheros
  
  NSURL *url =[fMng URLForDirectory:NSDocumentDirectory                           // Le pide el directorio de los documentos
                           inDomain:NSUserDomainMask 
                  appropriateForURL:nil 
                             create:YES 
                              error:nil];
  
  return [[url path] stringByAppendingPathComponent:@"Scenes.dat"];               // Le adiciona el nombre del fichero para los datos
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Lee todos los datos de la aplicación desde fichero
+ (GlobalData *)Load
  {
  NSString   *File = [GlobalData FileAppData];                                    // Obtiene el nombre del fichero para los datos
  GlobalData *This = [NSKeyedUnarchiver unarchiveObjectWithFile:File];            // Deserializa el objeto con los datos desde el fichero

  if( This == nil )                                                               // No sepudieron obtener los datos
    {
    This = [[GlobalData alloc] init];                                             // Crea un objeto vacio

    [This IniScenesFromBundle];                                                   // Obtiene los datos analizando el contenido del paquete
    
    [This Save];                                                                  // Guarda los datos para la proxima ves
    }
  
  return This;                                                                    // Retorna el objeto con los datos obtenidos
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Guarda los datos de la aplicación a un fichero
- (BOOL) Save
  {
  NSString * File = [GlobalData FileAppData];                                     // Obtiene el nombre del fichero para los datos
  
  return [NSKeyedArchiver archiveRootObject:self toFile:File];                    // Serializa los datos del objeto hacia el fichero
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Inicia la información de las escenas leyendo el contenido del paquete instalado
- (void) IniScenesFromBundle
  {
  Scenes = [NSMutableArray array];                                                // Crea un arreglo vacio para las scenas

  NSString *Path =[[NSBundle mainBundle] bundlePath];                             // Obtiene el directorio donde se instalo el paquete

  NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath: Path ];    // Crea enumerador de ficheros en el directorio

  NSString *file;
  while( file=[dirEnum nextObject])                                               // Recorre todos los ficheros del directorio  
    {
    if( [[file pathExtension] isEqualToString: @"scene"] )                        // Si tiene una extensión de escena
      {
      DataScene* data = [self GetDataScene:file];                                 // Obtiene los datos de la escena
    
      if( data ) [Scenes addObject: data];                                        // Adiciona los datos de la escena al arreglo
      }
  
    [dirEnum skipDescendants ];                                                   // Salta los subdirectorios desendientes
    }
  
  IdxScene = 0;                                                                   // Asume la primera escena como la actual
  Zoom     = -1;                                                                  // Columnas de escenas a mostrar
  _Sound   = 1;                                                                   // Sonido activo por defecto
  
#ifdef FREE_TO_PLAY                                                               // Inicializa los productos comprados
  PurchaseNoAds     = FALSE;
  PurchaseUnlock    = FALSE;
  PurchaseSolLavel1 = FALSE;
  PurchaseSolLavel2 = FALSE;
  PurchaseSolLavel3 = FALSE;
#endif
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el camino completo del fichero, con respecto al Bundle
- (NSString*) GetFullPath:(NSString*) fName
  {
  NSString *Path =[[NSBundle mainBundle] bundlePath];                             // Obtiene el directorio donde se instalo el paquete
  
  return [Path stringByAppendingPathComponent:fName];
  }
  
//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene todos los datos de la escena especificada por 'fName'
- (DataScene* ) GetDataScene: (NSString*) fName
  {
  NSString* FullName = [self GetFullPath:fName];
  NSDictionary *fData = [SceneData OpenSceneFile:FullName ];                      // Lee y parsea el fichero de la escena
  if(!fData ) return nil;                                                         // Verifica si se pudo leer bien
  
  DataScene* data = [DataScene alloc];                                            // Crea objeto vacio para datos de la escena
    
  data.Path   = fName;                                                            // Guarda la localizacion del fichero de definicion de la escena
  data.Puntos = 0;                                                                // Asume que la escena no se ha completado
  data.Fondo  = [fData objectForKey:@"ImgFondo" ];                                // Obtiene imagen de fondo de la escena
  
  NSNumber *Lock = [fData  objectForKey:@"Lock" ];                                // Obtiene si la escena esta bloqueada
  data.Lock      = ( Lock!=0 );                                                   // Convierte y asigna el valor
    
  return data;                                                                    // Retorna objeto con datos de la escena
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Serializa los datos del objeto
- (void)encodeWithCoder:(NSCoder *)aCoder
  {
  [aCoder encodeInt:IdxScene  forKey:@"IdxScene" ];
  [aCoder encodeInt:Zoom      forKey:@"ZoomSel"  ];
  [aCoder encodeInt:_Sound    forKey:@"Sound"    ];
  
  [aCoder encodeObject:Scenes forKey:@"Scenes"   ];
  
#ifdef FREE_TO_PLAY
  [aCoder encodeBool:PurchaseNoAds     forKey:@"PurchaseNoAds"     ];
  [aCoder encodeBool:PurchaseUnlock    forKey:@"PurchaseUnlock"    ];
  [aCoder encodeBool:PurchaseSolLavel1 forKey:@"PurchaseSolLavel1" ];
  [aCoder encodeBool:PurchaseSolLavel2 forKey:@"PurchaseSolLavel2" ];
  [aCoder encodeBool:PurchaseSolLavel3 forKey:@"PurchaseSolLavel3" ];
#endif
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Crea un objeto desde un fichero
- (id)initWithCoder:(NSCoder *)aDecoder
  { 
  self = [super init];
  if( self != nil )
    {
    IdxScene = [aDecoder decodeIntForKey:@"IdxScene" ];
    Zoom     = [aDecoder decodeIntForKey:@"ZoomSel"  ];
    _Sound   = [aDecoder decodeIntForKey:@"Sound"    ];
    
    Scenes   = [aDecoder decodeObjectForKey:@"Scenes"   ]; 
  
#ifdef FREE_TO_PLAY
    PurchaseNoAds     = [aDecoder decodeBoolForKey:@"PurchaseNoAds"     ];
    PurchaseUnlock    = [aDecoder decodeBoolForKey:@"PurchaseUnlock"    ];
    PurchaseSolLavel1 = [aDecoder decodeBoolForKey:@"PurchaseSolLavel1" ];
    PurchaseSolLavel2 = [aDecoder decodeBoolForKey:@"PurchaseSolLavel2" ];
    PurchaseSolLavel3 = [aDecoder decodeBoolForKey:@"PurchaseSolLavel3" ];
#endif
    }
    
  return self; 
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Wraper algunas propiedades
- (int) nScenes  { return (int)Scenes.count; }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la localización del fichero con la definicion de la escena actual
- (NSString*) NowPath { return [self PathAt:IdxScene];}
- (NSString*) PathAt:(int) idx
  {
  if( idx<0 || idx>=Scenes.count ) return NULL;
  
  return [self GetFullPath: ((DataScene *)Scenes[idx]).Path];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la localización del fichero con la imagen de fondo de la escena actual
- (NSString*) NowFondo { return [self FondoAt:IdxScene ]; }
- (NSString*) FondoAt:(int) idx
  {
  if( idx<0 || idx>=Scenes.count ) return NULL;
  return ((DataScene *)Scenes[idx]).Fondo;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la cantidad de puntos obtenidos en una escena
- (int) NowPuntos { return [self PuntosAt:IdxScene];  }
- (int) PuntosAt:(int) idx
  {
  if( idx<0 || idx>=Scenes.count ) return 0;
  
  return ((DataScene *)Scenes[idx]).Puntos;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Retorna numero de estrellas otorgadas, según la clasificación de la escena 'idx'
- (int) StarsAt:(int) idx
  {
  return [self GetStars:[self PuntosAt:idx]];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Retorna si la escena 'idx' esta bloqueada o no
- (BOOL) isLockAt:(int) idx
  {
  #ifdef FREE_TO_PLAY
    return ((DataScene *)Scenes[idx]).Lock;
  #else
    return FALSE;
  #endif
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Desbloquea todas las escenas
- (void) UnLockAll
  {
  #ifdef FREE_TO_PLAY
  PurchaseUnlock = TRUE;
  
  for( DataScene* scene in Scenes )
    scene.Lock = FALSE;
    
  Pages = nil;
  #endif
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Retorna numero de estrellas otorgadas, según la clasificación obtenida
- (int) GetStars:(int) puntos
  {
  if( puntos>490 ) return 5;
  if( puntos>460 ) return 4;
  if( puntos>410 ) return 3;
  if( puntos>350 ) return 2;
  if( puntos>280 ) return 1;
  
  return 0;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Establece la cantidad de puntos obtenidos en la escena actual
- (void) setNowPuntos: (int) puntos
  {
  int idx = IdxScene;
  if( idx<0 || idx>=Scenes.count ) return;
  
  ((DataScene *)Scenes[idx]).Puntos = puntos;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el numero total de puntos obtenidos en la escena
- (long) getTotalPnts
  {
  long total = 0;
  for( int i=0; i<AppData.nScenes; ++i )
    total += [AppData PuntosAt:i];
    
  return total;  
  }

@end

//=========================================================================================================================================
// Datos pertenecientes a un escena
@implementation DataScene
  @synthesize Path, Fondo, Puntos, Lock;

//-----------------------------------------------------------------------------------------------------------------------------------------
// Serializa los datos hacia un fichero
- (void)encodeWithCoder:(NSCoder *)aCoder
  {
//  Puntos = [NSNumber numberWithInt:(rand()%5000)]; 
  
  [aCoder encodeObject:Path   forKey:@"Path"  ];
  [aCoder encodeObject:Fondo  forKey:@"Fondo" ];
  [aCoder encodeInt   :Puntos forKey:@"Puntos"];
  [aCoder encodeBool  :Lock   forKey:@"Lock"  ];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Serializa los desde un fichero
- (id)initWithCoder:(NSCoder *)aDecoder
  { 
  self = [super init];
  if( self != nil )
    {
    Path   = [aDecoder decodeObjectForKey:@"Path"  ];
    Fondo  = [aDecoder decodeObjectForKey:@"Fondo" ]; 
    Puntos = [aDecoder decodeIntForKey   :@"Puntos"];
    Lock   = [aDecoder decodeBoolForKey  :@"Lock"  ];
    }
    
  return self; 
  }

@end

//=========================================================================================================================================
