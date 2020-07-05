//
//  HelpController.m
//  PusherGame
//
//  Created by Camilo Monteagudo on 21/05/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "HelpController.h"
#import "SceneData.h"
#import "Sound.h"

//=========================================================================================================================================
@interface HelpController ()
  {
  UIImage *HandUp;                // Imagen de la mano levantada
  UIImage *HandDwn;               // Imagen de la mano tocando la pantalla

  int  NowTopic;                  // Topico actual que se esta demostrando de la ayuda
  int  NowStep;                   // Estapa del topico que se esta mostrando

  NSThread* nowThread;            // Hilo donde se van a ejcutar todoas las etapas

  bool PlayTopic;                 // Indica si se reproducen los topicos o no
  bool NextTopic;                 // Indica si reproducir el topico siguiente o el actual
  }

@end

//=========================================================================================================================================
// Controlador para mostrar la ayuda del juego
@implementation HelpController
@synthesize Pusher, HelpZone, btnNextTopic, btnPrevTopic, btnRepitTopic, TopicDesc, Hand, HelpFrame;
@synthesize Target1, Target2, Target3, Target4, Block1, Block2, Block3, Block4;

// Define los topicos que componen la ayuda
NSString *Topics[] = { @"HlpPath", @"HlpMove", @"HlpContinue", @"HlpSimpleTarget", @"HlpComplexTarget" };

#define N_TOPIC ( sizeof(Topics) / sizeof(NSString *) )

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  [super viewDidLoad];
  
  NowTopic  = 0;
  nowThread = [NSThread currentThread];
  
  if( HandUp  == nil ) HandUp  = [UIImage imageNamed:@"HandUp"  ]; 
  if( HandDwn == nil ) HandDwn = [UIImage imageNamed:@"HandDown"]; 

	CGSize sz = self.view.bounds.size;
  CGRect rc = HelpFrame.frame;
	if( sz.width > 2*rc.size.width ) 
  	{ 
    HelpFrame.transform = CGAffineTransformMakeScale( 2.0, 2.0 );

    rc = HelpFrame.frame;
		rc.origin.y = sz.height - rc.size.height;
    
    HelpFrame.frame = rc;
    }
  
  [self PlayHelpTopic];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Muestra la pantalla incial del topico actual
- (void)PlayHelpTopic
	{
  TopicDesc.text = @"";
  
  [self PuherStop];
  [self BotonsShow:FALSE];
  [self HideAll];
  
  Pusher.transform = CGAffineTransformMakeRotation(0);
    
  NowStep = 0;
  NextTopic = FALSE;
  
  SEL fun = NSSelectorFromString( Topics[NowTopic] );
 
  [self performSelector:fun onThread:nowThread withObject:nil waitUntilDone:NO];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Muestra el siguiente pasa para el topico actual, si no hay mas pasos no hece nada
- (void)PlayNextStep
	{
  if( !PlayTopic ) return;
  
  ++NowStep;
  
  NSString *FunName = [Topics[NowTopic] stringByAppendingFormat:@"%d", NowStep];
  
  SEL fun = NSSelectorFromString( FunName );
  
  if( ![self respondsToSelector:fun] )
    return;
   
  [self performSelector:fun onThread:nowThread withObject:nil waitUntilDone:NO];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Ejecutas las tareas cumunes de la ultima etapa
- (void)EndStep
	{
  NextTopic = TRUE;                       // Pasar al proximo topico automaticamente
  NowStep   = 0;                          // Empezar por la primera estapa
  PlayTopic = FALSE;                      // Parar todos las animaciones
  [self PuherStop];                       // Detiene el movimeiento del pusher
  
	[self BotonsShow:TRUE];                 // Mostrar los botones
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Ocualta todas las vistas que estan sobre la zona de ayuda
- (void) HideAll
	{
  Pusher.hidden = TRUE;
  Hand.hidden   = TRUE;
  
  Target1.hidden = TRUE;
  Target2.hidden = TRUE;
  Target3.hidden = TRUE;
  Target4.hidden = TRUE;
  
  Block1.hidden = TRUE;
  Block2.hidden = TRUE;
  Block3.hidden = TRUE;
  Block4.hidden = TRUE;
  
  [TimeLabel removeFromSuperview];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Muestra los botones de navegación por lo topicos de la ayuda
- (void) BotonsShow:(BOOL) show
	{
  bool hide = (!show && PlayTopic);
  
  btnPrevTopic.hidden  = hide;
  btnNextTopic.hidden  = hide;
  
  NSString* ImgName = (PlayTopic) ? @"StopHelp" : @"PlayHelp";
  UIImage * Img     = [UIImage imageNamed: ImgName ];
    
  [btnRepitTopic setImage:Img forState:UIControlStateNormal ];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Comiensa el amimación del pusher en movimiento
- (void) PuherStartWalk
	{
  Pusher.animationImages = Scene.Pusher.GetAnimImgs;
  Pusher.animationDuration = 0.2;
  [Pusher startAnimating];
  
  [Sound PlayWalking];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Mustra el pusher estatico
- (void) PuherStop
	{
  [Pusher stopAnimating];
  [Sound StopWalking];
  
	Pusher.image = [UIImage imageNamed:Scene.Pusher.Name]; 
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene coordenadas del pusher y del la mano
- (float) PuherX { return Pusher.frame.origin.x + (Pusher.frame.size.width/2 );	}
- (float) PuherY { return Pusher.frame.origin.y + (Pusher.frame.size.height/2);	}

- (float) HandX	{ return Hand.frame.origin.x; }
- (float) HandY	{	return Hand.frame.origin.y; }

- (float) HandPntX	{ return Hand.frame.origin.x + 20; }
- (float) HandPntY	{	return Hand.frame.origin.y + 25; }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Mueve una vista a la posición indicada
- (void) MoveView:(UIView *)view  X:(int)x Y:(int)y 
	{
  CGRect rc = view.bounds;
  rc.origin = CGPointMake(x, y);
  
  view.frame = rc;
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Mueve una vista la magnitud indicada con respecto a lo posición actual
- (void) MoveView:(UIView *)view  DX:(int)dx DY:(int)dy
	{
  CGRect rc = view.frame;
  rc.origin.x += dx;
  rc.origin.y += dy;
  
  view.frame = rc;
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Carga una imagen a una vista de imagenes y la posiciona en la localización indicada
- (void) LoadImgView:(UIImageView *)img  Name:(NSString*)name X:(int)x Y:(int)y
	{
  img.image  = [UIImage imageNamed:name];
  
  if( img==Block1 )
    {
    CGRect rc = img.frame;
    if( [name isEqualToString:@"TargetMult.jpg"] )
      {
      rc.size.width  = 80;
      rc.size.height = 80;
      }
    else
      {
      rc.size.width  = 40;
      rc.size.height = 40;
      }
      
    img.frame = rc;
    }
  
  [self MoveView:img X:x Y:y];
  
  img.hidden = false;
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Mueve una vista animada con respecto a su posicion actual, cuando termine la animación continua con la funcion indicada
- (void) MoveAnimView:(UIView*)view DX:(int)dx DY:(int)dy Time:(float)tm Delay:(float)start Next:(BOOL)nxt
	{
  if( !PlayTopic ) return;
    
  [UIView animateWithDuration:tm delay:start options:0
                   animations: ^{
                     						[self MoveView:view DX:dx DY:dy];
                   							}
                   completion: ^(BOOL f)                                            // Al terminar la animación
   															{
                                if(nxt) [self PlayNextStep];
   															} ];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Rota el pusher animandolo el angulo indicado, cuando termine la animación continua con la función indicada
- (void) RotatePusherAng:(float)ang Next:(BOOL)nxt
	{
  [UIView animateWithDuration: 0.2
                   animations:^{
                               Pusher.transform = CGAffineTransformMakeRotation(ang);
                               } 
                   completion: ^(BOOL f)                                            // Al terminar la animación
   														 {
                               if(nxt) [self PlayNextStep];
													     } ];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Espera un tiempo 'tm' y luego ejecuta el metodo 'nextFun'
- (void) WaitTime:(float)tm Next:(BOOL)nxt
	{
  if( !PlayTopic ) return;
  
  id obj = nil;
  if( nxt ) obj = [NSObject alloc];
  
  [NSTimer scheduledTimerWithTimeInterval:tm target:self selector:@selector(EndTime:) userInfo:obj repeats:NO];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Al final del tiempo ejecuta la proxima etapa, si fue indicado
- (void)EndTime: (NSTimer *) timer
  {
  if( timer.userInfo ) [self PlayNextStep];
	}


//-----------------------------------------------------------------------------------------------------------------------------------------

int     nowDraw;          // Identificador del dibujo que se esta animando
int     endLen;           // Londitud final del dibujo cuando termine la animación
int     nowLen;           // Longitud actual de la animación
UIView* nowView;          // Vista adicional que se anima, simultaneamente con el dibujo
float   Delta;            // Magnitud en la que se altera la longitud del dibujo en cada animación

//-----------------------------------------------------------------------------------------------------------------------------------------
// Cambia el tamaño de forma animada de uno de los dibujos realizados en la vista, al final de la animación ejecuta una función
- (void) ResizeAnimDraw:(int)IdDraw View:(UIView*)view Len:(int)len Time:(float)tm Next:(BOOL)nxt
	{
  nowDraw = IdDraw;
  endLen  = len;
  nowLen  = 0;
  nowView = view;
  
  float rate = 1.0/30.0;
  Delta   = ((len-nowLen) / tm) * rate;
  
  id obj = nil;
  if( nxt ) obj = [NSObject alloc];
  
	[NSTimer scheduledTimerWithTimeInterval:rate target:self selector:@selector(OnResizeDraw:) userInfo:obj repeats:YES];
	}

//---------------------------------------------------------------------------------------------------------------------------
// Funcion que se llama durante la animación de un dibujo
- (void)OnResizeDraw: (NSTimer *) timer
  {
  nowLen += Delta;
  
  if( nowView!= 0 )
    {
    if( nowDraw==HLINE ) [self MoveView:nowView DX:Delta DY:0     ];
    else                 [self MoveView:nowView DX:0     DY:-Delta];
    }
    
  if( nowDraw!= 0 ) [HelpZone IncLenDt:Delta Draw:nowDraw];
  
  if( nowLen >= endLen )
    {
    BOOL nxt = (timer.userInfo!=nil);
    
    [timer invalidate];
    
    if( nxt ) [self PlayNextStep];
    }
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Crea una etiqueta en y la muestra en la zona de ayuda
UILabel *TimeLabel;

- (void) CreateLabel:(NSString *)resKey X:(int)x Y:(int)y  	
	{
  TimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 80, 20)];
  TimeLabel.text = NSLocalizedString( resKey, nil );
  TimeLabel.font = [UIFont boldSystemFontOfSize:10];
  TimeLabel.tag  = 100;
  TimeLabel.textAlignment = NSTextAlignmentRight;
  TimeLabel.backgroundColor = [UIColor whiteColor];
  TimeLabel.textColor       = [UIColor blackColor];
    
  [HelpZone addSubview:TimeLabel];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Pasa al topico anterior de la ayuda
- (IBAction)OnPrevTopic:(id)sender 
	{
  if( NowTopic>0 ) --NowTopic;
  else               NowTopic = N_TOPIC-1;
    
  PlayTopic = false;
  [self PlayHelpTopic];
	}
  
//-----------------------------------------------------------------------------------------------------------------------------------------
// Pasa al proximo topico de la ayuda
- (IBAction)OnNextTopic:(id)sender
	{
  if( NowTopic < N_TOPIC-1 ) ++NowTopic;
  else                         NowTopic=0;
  
  PlayTopic = false;
    
  [self PlayHelpTopic];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Reproduce el topico actual de la ayuda
- (IBAction)OnRepitTopic:(id)sender
	{
  PlayTopic = !PlayTopic;
  
  [self BotonsShow:TRUE];
  
  if( PlayTopic )
    {
    if( NextTopic )
      {
      if( NowTopic < N_TOPIC-1 ) ++NowTopic;
      else                         NowTopic=0;
      }
    
    if( NowStep == 0 ) [self PlayHelpTopic];
    else               [self PlayNextStep ];
    }
	}

//=========================================================================================================================================
// DEMOSTRACIÓN DE COMO SE DEFINE EL CAMINO
//-----------------------------------------------------------------------------------------------------------------------------------------
// Pone el pusher y la mano en la posición inicial
- (void) HlpPath
	{
  TopicDesc.text = NSLocalizedString( @"PathTopic", nil );
  Hand.image = HandUp;
  
  [self MoveView:Pusher X:40  Y:180];
  [self MoveView:Hand   X:240 Y:80 ];

  Pusher.hidden = FALSE;
  Hand.hidden   = FALSE;
  [HelpZone SetDraw:0 ];
  
  [self MoveAnimView:Hand DX:-160 DY:160 Time:1 Delay:1 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Muestra la flecha de desplazamiento horizontal
- (void) HlpPath1
	{
  Hand.image = HandDwn;
  
  float x = [self HandPntX] + 10;
  float y = [self HandPntY];
  
  [HelpZone DrawHorzFlechaX:x Y:y Lng:1];
  [self ResizeAnimDraw:HFLECHA View:nil Len:160 Time:1 Next:YES];
	}
  
//-----------------------------------------------------------------------------------------------------------------------------------------
// Mustra definición de segmento horizontal
- (void) HlpPath2
	{
  [HelpZone SetDraw:0 ];
  
  float x = [self PuherX];
  float y = [self PuherY];
    
  [HelpZone DrawHorzLineX:x Y:y Lng:1];
  
  [self ResizeAnimDraw:HLINE View:Hand Len:160 Time:1 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Muestra la flecha de desplazamiento vertical
- (void) HlpPath3
	{
  float x = [self HandPntX];
  float y = [self HandPntY] - 10;
  
  [HelpZone DrawVertFlechaX:x Y:y Lng:1];
  [self ResizeAnimDraw:VFLECHA View:nil Len:160 Time:1 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Mustra definición de segmento vertical
- (void) HlpPath4
	{
  [HelpZone SetDraw:HLINE ];
  
  CGPoint pnt = [HelpZone GetEndDraw:HLINE ];
  [HelpZone DrawVertLineX:pnt.x Y:pnt.y Lng:1];
    
  [self ResizeAnimDraw:VLINE View:Hand Len:160 Time:1 Next:YES];
	}
  
//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpPath5
	{
  [self EndStep];
  }

//=========================================================================================================================================
// DEMOSTRACIÓN DEL INICIO DEL MOVIMIENTOS DEL PUSHER
//-----------------------------------------------------------------------------------------------------------------------------------------
// Muestra el pucher, la mano y el camino
- (void) HlpMove
	{
  TopicDesc.text = NSLocalizedString( @"MoveTopic", nil );
  Hand.image = HandDwn;
  
  [HelpZone SetDraw:0 ];
  
  [self MoveView:Pusher X:40  Y:180];
  [self MoveView:Hand   X:240 Y:80];

	float x = [self PuherX];
  float y = [self PuherY];
    
  [HelpZone DrawHorzLineX:x Y:y Lng:160];
  
  CGPoint pnt = [HelpZone GetEndDraw:HLINE ];
  [HelpZone DrawVertLineX:pnt.x Y:pnt.y Lng:160];
  
  Pusher.hidden = FALSE;
  Hand.hidden   = FALSE;
  
  [self WaitTime:1 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Muestra el carter de espera y espera 1.5 seg antes de continuar con la otra fase
- (void) HlpMove1
	{
  Hand.image = HandUp;
  
  float x = [self HandX];
  float y = [self HandY];
    
  [self CreateLabel:@"TimeLabel1" X:x-70 Y:y];  
  
  [self WaitTime:1.5 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Quita el cartel, anima movimiento del pusher por la horizontal y retira la mano
- (void) HlpMove2
	{
  [TimeLabel removeFromSuperview];
    
  [self PuherStartWalk];
  
  [self MoveAnimView: Hand   DX:100 DY:100 Time:2   Delay:1 Next:NO ];
  [self MoveAnimView: Pusher DX:160 DY:0   Time:1.5 Delay:0 Next:YES];
	}
  
//-----------------------------------------------------------------------------------------------------------------------------------------
// Anima rotación del pusher y retira camino horizontal
- (void) HlpMove3
	{
  [HelpZone SetDraw:VLINE ];
  
  [self RotatePusherAng:3*M_PI/2 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Anima movimiento del puher por la vertical
- (void) HlpMove4
	{
  [self MoveAnimView:Pusher DX:0 DY:-160 Time:1.5 Delay:0 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Quita camino horizontal y detiene el puscher, termina la demostración
- (void) HlpMove5
	{
  [HelpZone SetDraw:0 ];
  
  [self EndStep];
	}

//=========================================================================================================================================
// DEMOSTRACIÓN DE COMO CONTINUAR LA DEFINICIÓN DEL CAMINO CAMBIANDO DEL DEDO DE POSICIÓN
//-----------------------------------------------------------------------------------------------------------------------------------------
// Posiciona y muestra al pusher la mano y el camino vertical
- (void) HlpContinue
	{
  [HelpZone SetDraw:0 ];                                          // Borra cualquier dibujo enterior
  
  TopicDesc.text = NSLocalizedString( @"ContTopic", nil );        // Pone el cadene con el nombre del demo
  Hand.image = HandDwn;                                           // Carga imagen de con dedo tocando la pantalla
  
	Pusher.transform = CGAffineTransformMakeRotation(3*M_PI/2);     // Rota el pusher 90
  [self MoveView:Pusher X:40 Y:180];                              // Mueve el pusher a la posición de inicio
  
  [HelpZone DrawVertLineX:60 Y:200 Lng:120];                      // Dibuja el camino vertical
  
  [self MoveView:Hand X:240 Y:80];                                // Pone el mano en la pocisión inicial
  
  Pusher.hidden = FALSE;                                          // Garantiza que el pusher se muestre
  Hand.hidden   = FALSE;                                          // Garantiza que la mano se muestre
  
  [self WaitTime:1 Next:YES];                                     // Espera un segundo y continua con la proxima etapa
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Pone el cartelito, y mueve la mano a otra posición despues de esperar 1 seg.
- (void) HlpContinue1
	{
  Hand.image = HandUp;                                            // Pone mano con dedo levantado
  
  float x = [self HandX];                                         // Obtiene la posición de la mano
  float y = [self HandY];
  
  [self CreateLabel:@"TimeLabel2" X:x-70 Y:y];                    // Pone cartelito, proximo a la mano
  
  [self MoveAnimView:Hand DX:-200 DY:160 Time:1 Delay:1 Next:YES];      // Mueve la mano y continua
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
// Quita el cartelito y pone la flecha indicado el moviviento horizontal
- (void) HlpContinue2
	{
  Hand.image = HandDwn;                                           // Pone la mano con el dedo hacia abajo
    
  [self WaitTime:0.5 Next:YES];
  }
  
//-----------------------------------------------------------------------------------------------------------------------------------------
// Quita el cartelito y pone la flecha indicado el moviviento horizontal
- (void) HlpContinue3
	{
  [TimeLabel removeFromSuperview];                                // Quita el cartelito
  
  float x = [self HandPntX] + 10 ;                                // Obtiene la posición de la mano
  float y = [self HandPntY];
    
  [HelpZone DrawHorzFlechaX:x Y:y Lng:1];                         // Crea la flecha pequeña
  [self ResizeAnimDraw:HFLECHA View:nil Len:160 Time:1 Next:YES];      // Estira la flecha y conyinua
  }
  
//-----------------------------------------------------------------------------------------------------------------------------------------
// Borra la flecha y define camino horizontal
- (void) HlpContinue4
	{
  [HelpZone SetDraw:VLINE ];                                      // Borra la flecha y deja camino vertical
    
  CGPoint pnt = [HelpZone GetEndDraw:VLINE ];
  [HelpZone DrawHorzLineX:pnt.x Y:pnt.y Lng:1];                   // Crea linea vertical pequeña
  
  [self ResizeAnimDraw:HLINE View:Hand Len:160 Time:1 Next:YES];  // Estira la linea, mueve la mano y continua
  }
  
//-----------------------------------------------------------------------------------------------------------------------------------------
// Termina la demostración
- (void) HlpContinue5
	{
  [self EndStep];
	}

//=========================================================================================================================================
// DEMOSTRACIÓN DE LOS TARGETS SIMPLES
//-----------------------------------------------------------------------------------------------------------------------------------------
// Pone todos elementos de la demostración en la zona de ayuda
- (void) HlpSimpleTarget
	{
  [HelpZone SetDraw:0 ];                                          // Borra cualquier dibujo enterior
  
  TopicDesc.text = NSLocalizedString( @"Targets1Topic", nil );    // Pone el cadene con el nombre del demo
  
  [self LoadImgView:Block1 Name:@"Bloque-Amarillo" X:80 Y:60 ];
  [self LoadImgView:Block2 Name:@"Bloque-Estrella" X:80 Y:180];
  [self LoadImgView:Block3 Name:@"Bloque-Rojo"     X:80 Y:220];
  [self LoadImgView:Block4 Name:@"Bloque-Piedra"   X:40 Y:140];
  
  [self LoadImgView:Target1 Name:@"TargetGreen"    X:200 Y:60 ];
  [self LoadImgView:Target2 Name:@"TargetBlue"     X:200 Y:180];
  [self LoadImgView:Target3 Name:@"TargetRed"      X:200 Y:220];
  
  [self MoveView:Pusher X:0 Y:60];                                  // Mueve el pusher a la posición de inicio
  Pusher.hidden = FALSE;                                           // Garantiza que el pusher se muestre
  
  [self WaitTime:1 Next:YES];             // Espera un segundo y continua con la proxima etapa
	}

// Ejecuta la serie de movimentos del pusher y de los bloques
//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpSimpleTarget1
	{
  [self PuherStartWalk];
  
  [self MoveAnimView:Pusher DX:40 DY:0 Time:0.5 Delay:0 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpSimpleTarget2
	{
  [self MoveAnimView:Pusher DX:120 DY:0 Time:1 Delay:0 Next:NO ];
  [self MoveAnimView:Block1 DX:120 DY:0 Time:1 Delay:0 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpSimpleTarget3
	{
  [self RotatePusherAng:M_PI Next:NO ];
  [self MoveAnimView:Pusher DX:-120 DY:0 Time:1 Delay:0.3 Next:YES];
  }
  
//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpSimpleTarget4
	{
  [self RotatePusherAng:M_PI/2 Next:NO ];
  [self MoveAnimView:Pusher DX:0 DY:40 Time:0.5 Delay:0.3 Next:YES];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpSimpleTarget5
	{
  [self MoveAnimView:Pusher DX:0 DY:80 Time:0.7 Delay:0 Next:NO ];
  [self MoveAnimView:Block4 DX:0 DY:80 Time:0.7 Delay:0 Next:YES];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpSimpleTarget6
	{
  [self RotatePusherAng:0 Next:NO ];
  [self MoveAnimView:Pusher DX:120 DY:0 Time:1 Delay:0.3 Next:NO ];
  [self MoveAnimView:Block2 DX:120 DY:0 Time:1 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpSimpleTarget7
	{
  [self RotatePusherAng:M_PI Next:NO ];
  [self MoveAnimView:Pusher DX:-120 DY:0 Time:1 Delay:0.3 Next:YES];
  }
  
//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpSimpleTarget8
	{
  [self RotatePusherAng:M_PI/2 Next:NO ];
  [self MoveAnimView:Pusher DX:0 DY:40 Time:0.5 Delay:0.3 Next:NO ];
  [self MoveAnimView:Block4 DX:0 DY:40 Time:0.5 Delay:0.3 Next:YES];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpSimpleTarget9
	{
  [self RotatePusherAng:0 Next:NO ];
  [self MoveAnimView:Pusher DX:120 DY:0 Time:1 Delay:0.3 Next:NO ];
  [self MoveAnimView:Block3 DX:120 DY:0 Time:1 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpSimpleTarget10
	{
  [self EndStep];
  }

//=========================================================================================================================================
// DEMOSTRACIÓN DE LOS TARGETS SIMPLES
//-----------------------------------------------------------------------------------------------------------------------------------------
// Pone todos elementos de la demostración en la zona de ayuda
- (void) HlpComplexTarget
	{
  [HelpZone SetDraw:0 ];                                          // Borra cualquier dibujo enterior
  
  TopicDesc.text = NSLocalizedString( @"Targets2Topic", nil );    // Pone el cadene con el nombre del demo
  
  [self LoadImgView:Block1 Name:@"TargetMult.jpg" X:120 Y:100 ];
  
  [self LoadImgView:Target1 Name:@"Rombo4" X:80  Y:100 ];
  [self LoadImgView:Target2 Name:@"Rombo3" X:160 Y:60  ];
  [self LoadImgView:Target3 Name:@"Rombo2" X:200 Y:140 ];
  [self LoadImgView:Target4 Name:@"Rombo1" X:120 Y:180 ];
  
  [self MoveView:Pusher X:0 Y:60];                                  // Mueve el pusher a la posición de inicio
  Pusher.hidden = FALSE;                                           // Garantiza que el pusher se muestre
  
  [self WaitTime:1 Next:YES];             // Espera un segundo y continua con la proxima etapa
	}

// Ejecuta la serie de movimientos del pusher y de los bloques hasta terminar la demostración
//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget1
	{
  [self PuherStartWalk];
  
  [self MoveAnimView:Pusher DX:40  DY:0 Time:0.5 Delay:0 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget2
	{
  [self RotatePusherAng:M_PI/2 Next:NO ];
  
  [self MoveAnimView:Pusher DX:0  DY:40 Time:0.5 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget3
	{
  [self RotatePusherAng:0 Next:NO ];
  
  [self MoveAnimView:Target1 DX:40 DY:0 Time:0.5 Delay:0.3 Next:NO ];
  [self MoveAnimView:Pusher  DX:40 DY:0 Time:0.5 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget4
	{
  [self RotatePusherAng:-M_PI/2 Next:NO ];
  
  [self MoveAnimView:Pusher DX:0  DY:-80 Time:1 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget5
	{
  [self RotatePusherAng:0 Next:NO ];
  
  [self MoveAnimView:Pusher DX:80  DY:0 Time:1 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget6
	{
  [self RotatePusherAng:M_PI/2 Next:NO ];
  
  [self MoveAnimView:Target2 DX:0 DY:40 Time:0.5 Delay:0.3 Next:NO ];
  [self MoveAnimView:Pusher  DX:0 DY:40 Time:0.5 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget7
	{
  [self RotatePusherAng:0 Next:NO ];
  
  [self MoveAnimView:Pusher DX:40 DY:0 Time:0.5 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget8
	{
  [self RotatePusherAng:M_PI/2 Next:NO ];
  
  [self MoveAnimView:Pusher DX:0 DY:40 Time:0.5 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget9
	{
  [self RotatePusherAng:0 Next:NO ];
  
  [self MoveAnimView:Pusher DX:40 DY:0 Time:0.5 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget10
	{
  [self RotatePusherAng:M_PI/2 Next:NO ];
  
  [self MoveAnimView:Pusher DX:0 DY:40 Time:0.5 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget11
	{
  [self RotatePusherAng:M_PI Next:NO ];
  
  [self MoveAnimView:Target3 DX:-40 DY:0 Time:0.5 Delay:0.3 Next:NO ];
  [self MoveAnimView:Pusher  DX:-40 DY:0 Time:0.5 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget12
	{
  [self RotatePusherAng:M_PI/2 Next:NO ];
  
  [self MoveAnimView:Pusher DX:0 DY:80 Time:1.0 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget13
	{
  [self RotatePusherAng:-M_PI Next:NO ];
  
  [self MoveAnimView:Pusher DX:-80 DY:0 Time:1.0 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget14
	{
  [self RotatePusherAng:-M_PI/2 Next:NO ];
  
  [self MoveAnimView:Target4 DX:0 DY:-40 Time:0.5 Delay:0.3 Next:NO ];
  [self MoveAnimView:Pusher  DX:0 DY:-40 Time:0.5 Delay:0.3 Next:YES];
	}

//-----------------------------------------------------------------------------------------------------------------------------------------
- (void) HlpComplexTarget15
	{
  [self EndStep];
	}

@end
//=========================================================================================================================================
