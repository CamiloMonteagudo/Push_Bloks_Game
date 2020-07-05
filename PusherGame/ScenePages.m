//
//  ScenePages.m
//  SmartPusher
//
//  Created by Camilo on 23/11/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "ScenePages.h"
#import "SceneData.h"
#import "GlobalData.h"

#define WScene      320.0                     // Ancho de las escenas en puntos
#define HScene      480.0                     // Alto de las escenas en puntos
#define CountXLavel 18                        // Cantidad de escenas por nivel
#define Aspect      (HScene/WScene)           // Relación de aspecto de las escenas
#define MaxScenes   54

//=========================================================================================================================================
struct SceneIcon
  {
  CGRect rcIcon;
  CGRect rcFoot;
  int stars;
  int page;
  };

typedef struct SceneIcon SceneIcon;

//=========================================================================================================================================

@interface ScenePages()
  {	
  SceneIcon Iconos[ MaxScenes ];              // Guarda todos los datos de los iconos de las escenas
  UIImage*  Pages[10];                        // Imagenes de la páginas procesadas
  
  int nPages;                                 // Numero de paginas que hay

  CGSize sz;                                  // Tamaño de las páginas y de las imagenes
  
  int nCols;                                  // Número de columnas de iconos de escenas en la página
  int nRows;                                  // Número de filas de iconos de escenas en la página
  
  float xSep;                                 // Separación en la horizontal entre los iconos
  float ySep;                                 // Separación en la vertical entre los iconos
  
  float hFoot;                                // Altura del pie de página en puntos
  float hImgFoot;                             // Altura de la imagen del pie de página
  float wImgFoot;                             // Ancho de la imagen del pie de página
  
  float WIcon;                                // Ancho de los iconos de escenas
  float HIcon;                                // Alto de los iconos de escenas
  
  float xIni;                                 // Posición en la horizontal del primer icono en la escena
  float yIni;                                 // Posición en la vertical del primer icono en la escena
  
  float esc;                                  // Escala que se aplica a la escena para dibujarla dentro del icono
  
  UIColor *ColFondo;                          // Color del fondo de las escenas
  UIColor *ColFoot;                           // Calor de la franja donde se pone la puntuacion
  UIColor *ColNum;                            // Color de los numeros
  
  int LastScene;                              // Ultima escena que se dibujo el icono
  int nScenes;                                // Número de escenas en el juego
  }
@end

UIImage* Stars[6];

//=========================================================================================================================================
// Implementa el manejo de páginas con miniaturas de las escenas
@implementation ScenePages

//---------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa las páginas de un tamaño y número de filas y columnas dados
- (ScenePages*) initWithSize:(CGSize) size Cols:(int) Cols Rows:(int) Rows
  {
  self = [super init];
  if( !self ) return nil;
    
  sz    = size;
  nCols = Cols;
  nRows = Rows;
    
  hFoot = (12 * sz.height)/HScene;
  xSep  = 0.02 * sz.width;
    
  WIcon = (sz.width - (nCols+1) * xSep) / nCols;
  HIcon = Aspect * WIcon;
  ySep  = xSep;
  if( sz.height < ySep + (nRows * (HIcon+ySep+hFoot) - ySep) )
    {
    HIcon = (sz.height - 8 - (nRows * (ySep+hFoot)-ySep) ) / nRows;
    WIcon = HIcon / Aspect;
    xSep  = (sz.width - nCols*WIcon) / (nCols+1);
    }
  
  xIni = xSep;
  yIni = (sz.height - (nRows * (HIcon+ySep+hFoot) - ySep)  ) / 2;
    
  esc = WIcon/WScene;
    
  ColFondo = [UIColor colorWithRed:40.0/255 green:36.0/255 blue:96.0/255 alpha:0.6];
  ColFoot  = [UIColor colorWithRed:40.0/255 green:36.0/255 blue:96.0/255 alpha:1.0];
  ColNum   = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];

  nScenes = [AppData nScenes];
  
  [self PrepareFoot];
  
  return self;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Determina todos los datos necesario para dibujar la parte de abajo en la miniaruras de escenas
- (void) PrepareFoot
  {
  Stars[0] = [UIImage imageNamed:@"Stars0" ];
  Stars[1] = [UIImage imageNamed:@"Stars1" ];
  Stars[2] = [UIImage imageNamed:@"Stars2" ];
  Stars[3] = [UIImage imageNamed:@"Stars3" ];
  Stars[4] = [UIImage imageNamed:@"Stars4" ];
  Stars[5] = [UIImage imageNamed:@"Stars5" ];
    
  UIImage* Img = Stars[0];
  if( Img )
    {
    float w = Img.size.width * Img.scale;
    float h = Img.size.height * Img.scale;
    if( hFoot<h || WIcon<w )
      {
      w /= 2;
      h /= 2;
      }
  
    wImgFoot = w/esc;
    hImgFoot = h/esc;
    }
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Carga el arreglo con todas las páginas de escenas del juego
- (void) LoadPages
  {
  nPages  = 0;
  LastScene = 0;

  while( LastScene < nScenes )
    {
    Pages[nPages] = [self GetScenePageAt:LastScene ];
    ++nPages;
    }
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Retorna la página 'idx' dentro del arreglo de páginas
- (UIImage*) GetPage:(int) idx
  {
  if( idx<0 || idx>=nPages ) return nil;
  
  return Pages[idx];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Retorna la página 'idx' dentro del arreglo de páginas
- (int) PageCount
  {
  return nPages;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene una imagen con la página de miniaturas comenzando por la escena 'Num'
- (UIImage *) GetScenePageAt: (int) Num
  {
	UIGraphicsBeginImageContext( CGSizeMake( sz.width, sz.height ) );
  
  CGContextRef ct = UIGraphicsGetCurrentContext();                            // Obtiene el contecto
  
  CGContextScaleCTM ( ct, esc, esc );
  
  int idx   = Num;                                                            // Indice de la esena inicial de la página
  int Max   = Num + (nCols*nRows);                                            // Indice de la escena final de la página
  int lavel = Num / CountXLavel;                                              // Nivel a la que pertenece la primera escena
  int MaxLavel = (lavel+1)*CountXLavel;                                       // Indice a la última escena del nivel
  
  if( Max>MaxLavel ) Max = MaxLavel;                                          // Limita solo escenas de un nivel
  
  float y = yIni/esc;                                                         // Posición de las minuaturas para la primera fila
  
  for( int row=0; row<nRows && idx<Max; ++row )                               // Recorre todas las columnas
    {
    float x = xIni/esc;                                                       // Posición de la primera miniatura para primera columna
    for( int col=0; col<nCols && idx<Max; ++col )                             // Reorre todas las filas
      {
      CGRect rc = CGRectMake( x, y, WScene, HScene );                         // Calcula rectangulo de la miniatura

      [SceneBasicData DrawInContext:ct Rect:rc Scene:idx];                    // Dibuja contenido de la escena en rectangulo 'rc'
      [self SaveIconDataAt:idx Rect:rc ];                                     // Guarda datos del icono de la escena
      
      [self DrawImgNum:idx Context:ct InRect:rc ];                            // Dibuja numero
      [self DrawFootScene:idx Context:ct ];                                   // Dibuja el pie de la escena
      
      if( [AppData isLockAt:idx] )                                            // Si la escena esta bloqueada
        {
        float w = 1*WScene/2;                                                 // Calcula tamaño del icono del candado
        CGRect rc2 = CGRectMake( x, y, w, w );                                // Calcula rectangulo del candado
        [SceneBasicData DrawCacheImage:@"Lock" AtRect:rc2 ];                  // Dibuja el candado
        }
  
      x += WScene + xSep/esc;                                                 // Posición de la miniatura para la proxima columna
        
      ++idx;                                                                  // Indice a la proxima escena
      }
      
    y += HScene + (ySep+hFoot)/esc;                                           // Posición de las miniaturas para proxima fila
    }
    
	UIImage *Img=UIGraphicsGetImageFromCurrentImageContext();                   // Obtiene una imagen con el contenido del contexto
  
	UIGraphicsEndImageContext();                                                // Termina trabajo con el contexto
  
  LastScene = idx;
	return Img;                                                                 // Retorna la imagen
  }


//---------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene una imagen con la página de miniaturas comenzando por la escena 'Num'
- (void) SaveIconDataAt: (int) iScene Rect:(CGRect) rc
  {
  SceneIcon icon;
  icon.rcIcon = rc;
  icon.page   = nPages;
  icon.stars  = [AppData StarsAt: iScene];                                      // Número de estrellas segun la puntuación actual
  
  CGPoint pnt = rc.origin;
  icon.rcFoot = CGRectMake( pnt.x, pnt.y+HScene, WScene, hFoot/esc );

  Iconos[iScene] = icon;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Crea una imagen con el numero de la escena
- (void) DrawImgNum: (int) Num Context:(CGContextRef)ct InRect:(CGRect)rc1
  {
  CGFloat w = 0.125 * rc1.size.width;                                         // Calcula ancho para el número de la escena
  CGFloat x = rc1.origin.x + (rc1.size.width - w)/2;                          // Calcula para ponerlo en el centro por la horizontal
  CGFloat y = rc1.origin.y ;                                                  // Lo pone en la parte de arriba en la vertical
  
  NSString *sNum = [NSString stringWithFormat:@"%d", Num+1 ];                 // Convierte el número a cadena
  
	UIFont *font = [UIFont boldSystemFontOfSize: w - (0.25 * w) ];              // Calcula el tamaño del Font
	CGSize szStr = [sNum sizeWithFont:font];                                    // Obtiene tamaño del texto con el número
  
  CGRect rc = CGRectMake(x,y,w,w);                                            // Crea el rectangulo donde lo va a dibujar
    
  [ColFoot set];                                                              // Pone el color de fondo
  CGContextFillRect( ct, rc );                                                // Dibuja un rectangulo de fondo del numero
    
	[ColNum set];                                                               // Pone el tamaño de los caracteres
	CGPoint pnt = CGPointMake( x+(w-szStr.width)/2, y+(w-szStr.height)/2 );     // Calcula la posición
	[sNum drawAtPoint:pnt withFont:font];                                       // Pone el número
  }
  
//---------------------------------------------------------------------------------------------------------------------------------------------
// Dibuja el pie de la escena con la calificación obtenida
- (void)DrawFootScene:(int)idx Context:(CGContextRef)ct
  {
  SceneIcon icon = Iconos[idx];
  
  CGContextSetFillColorWithColor  (ct, ColFoot.CGColor );                       // Define color de llenado del pie de escena
  CGContextSetStrokeColorWithColor(ct, ColFoot.CGColor );                       // Define color del borde del pie de escena
  
  CGRect rc = icon.rcFoot;
  CGContextFillRect( ct, rc );                                                  // Dibuja el fondo del pie de la escena
  
  UIImage* Img = Stars[ icon.stars ];
  
  float x = rc.origin.x + (rc.size.width  - wImgFoot) / 2;
  float y = rc.origin.y + (rc.size.height - hImgFoot) / 2;
  
  [Img drawInRect: CGRectMake( x, y, wImgFoot, hImgFoot ) ];
  }
  
//---------------------------------------------------------------------------------------------------------------------------------------------
// Busca que escena se encuentra en el punto 'pnt' perteneciente a la pagina 'pg'
- (int) SceneAtPoint:(CGPoint)pnt Page:(int)pg
  {
  int idx = 0;
  while( pg != Iconos[idx].page && idx<nScenes ) ++idx;
  
  CGPoint pt = CGPointMake( pnt.x/esc, pnt.y/esc );
  
  while( pg ==Iconos[idx].page && idx<nScenes )
    {
    if( CGRectContainsPoint( Iconos[idx].rcIcon, pt ) )
      return idx;
      
    ++idx;
    }
    
  return -1;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Actualiza la informacion sobre las puntuaciones de las escenas
- (BOOL) UpdatePoints
  {
  int ini   = 0;
  int nowPg = 0;
  BOOL ret  = FALSE;
  
  for(int i=0; i<nScenes; ++i )
    {
    SceneIcon icon = Iconos[i];
    int         pg = Iconos[i].page;
    int      stars = [AppData StarsAt: i];
    
    if( pg != nowPg )
      {
      ini   = i;
      nowPg = pg;
      }
    
    if( stars != icon.stars )
      {
      ret = true;
      i = [self UpdatePage:nowPg IniScene:ini NowScene:i ];
      }
    }
    
  return ret;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Actualiza la informacion de la pagina 'pg' que empieza con la escena 'ini' a partir de la escena 'idx'
- (int) UpdatePage:(int)pg IniScene:(int)Ini NowScene:(int)idx
  {
  CGRect rc = CGRectMake(0, 0, sz.width, sz.height );
  UIGraphicsBeginImageContext( rc.size );
  CGContextRef ct = UIGraphicsGetCurrentContext();                            // Obtiene el contecto
  
  [Pages[pg] drawInRect:rc];
  
  CGContextScaleCTM ( ct, esc, esc );
  
  while( idx<nScenes && Iconos[idx].page==pg )
    {
    int stars = [AppData StarsAt: idx ];
    if( stars != Iconos[idx].stars )
      {
      Iconos[idx].stars = stars;
      [self DrawFootScene:idx Context:ct ];                                   // Dibuja el pie de la escena
      }
      
    ++idx;
    }
    
  Pages[pg] =UIGraphicsGetImageFromCurrentImageContext();                   // Obtiene una imagen con el contenido del contexto
  
  UIGraphicsEndImageContext();                                                // Termina trabajo con el contexto
  
  return idx-1;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Retorna el rectangulo que encierra el icono de la escena 'idx' referente a la esquina superior derecha de la pagina
- (CGRect) IconFrameScene:(int)idx
  {
  SceneIcon icon = Iconos[idx];
  
  CGRect rc = CGRectUnion( icon.rcIcon, icon.rcFoot );
  
  rc.origin.x    *= esc;
  rc.origin.y    *= esc;
  rc.size.width  *= esc;
  rc.size.height *= esc;
  
  return rc;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la página donde se encuenra la escena 'idx'
- (int) PageScene:(int)idx
  {
  return Iconos[idx].page;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------

@end
