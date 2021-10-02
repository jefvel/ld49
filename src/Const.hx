import hxd.impl.UInt16;

class Const {
    // Pixel scaling for the 2d scene
	public static inline final PIXEL_SIZE = 2;

    public static inline final GAP_SIZE = 1000.;
    public static inline final BULLETS_PER_GUN = 12;

    // Pixels per unit, in 3d space
    public static inline final PIXEL_SIZE_WORLD = 32;
    public static inline final PPU = 1.0 / PIXEL_SIZE_WORLD;

	public static inline final TICK_RATE = 60;
}