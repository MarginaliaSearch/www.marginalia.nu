#include <stdlib.h>
#include <math.h>
#include <fcntl.h>
#include <unistd.h>
#include "SDL.h"

#define WIDTH 1920
#define HEIGHT 1080
#define LENGTH 50000
#define LIMG   50
#define LIMB   1
#define SUBSTEP 0.125

#include <vector>
#include <utility>
#include <iostream>
#include <fstream>

using namespace std;

double mapr[WIDTH][HEIGHT];
double mapg[WIDTH][HEIGHT];
double mapb[WIDTH][HEIGHT];

double theta;
int Z = 0;
int W = 0;
const double SQRT2 = M_SQRT2*2.0;
double angle[6] = { 0, 0, 0, 0, 0, 0, } ;
vector<pair<double,double>> coords;
vector<pair<double,double>> origins;
vector<int> lens;
int li;

void mapbrot(double x, double y, double z, double w) {
	double cx = x + z, cy = y + w;
	double cx2 = cx*cx, cy2 = cy*cy;
	int iter = 0;
	double cx0 = cx;
	double cy0 = cy;

	vector<pair<double,double>> orbit;

//	orbit.push_back(make_pair(cy,cx));
	while(cx2+cy2 < 4) {
		if(iter++ > LENGTH) return;

		cy = 2*cx*cy + y;
		cx = cx2 - cy2 + x;
		cx2 = cx*cx;
		cy2 = cy*cy;

		orbit.push_back(make_pair(cy,cx));

		if(cx == cx0 && cy == cy0) return;
	}
	coords.insert(end(coords), begin(orbit), end(orbit));
	origins.push_back({x+z,y+w});
	lens.push_back(iter);
}

void render() {

	double ca0 = cos(angle[0]);
	double ca1 = cos(angle[1]);
	double ca2 = cos(angle[2]);
	double ca3 = cos(angle[3]);
	double ca4 = cos(angle[4]);
	double ca5 = cos(angle[5]);

	double sa0 = sin(angle[0]);
	double sa1 = sin(angle[1]);
	double sa2 = sin(angle[2]);
	double sa3 = sin(angle[3]);
	double sa4 = sin(angle[4]);
	double sa5 = sin(angle[5]);

	long iter = 0;
	for (int i = 0; i < lens.size(); i++) {
		double x = origins[i].first;
		double y = origins[i].second;


		int li = lens[i];
		for (int j = 0; j < li; j++,iter++) {

			double xp = coords[iter].first * ca0 - coords[iter].second * sa0;
			double yp = coords[iter].first * sa0 + coords[iter].second * ca0;
			double zp = x * ca1 - y * sa1;
			double wp = x * sa1 + y * ca1;

			double cxp = xp * ca2 - zp * sa2;
			double czp = xp * sa2 + zp * ca2;
			double cyp = yp * ca3 - wp * sa3;
			double cwp = yp * sa3 + wp * ca3;

			xp = cxp * ca4 - cwp * sa4;
			wp = cxp * sa4 + cwp * ca4;
			yp = cyp * ca5 - czp * sa5;
			zp = cyp * sa5 + czp * ca5;

			int xc = (WIDTH - HEIGHT) / 2 + (1.5*yp+2.5)*HEIGHT/4.0;
			int yc = (1.5*xp+2)*HEIGHT/4.0;

			if(xc>=0 && yc>=0 && xc < WIDTH && yc < HEIGHT) {

				mapr[xc][yc]+=j/(double) li;
				mapg[xc][yc]+=1 - j/(double) li;
			//mapg[xc][yc]++;
				mapb[xc][yc]++;
//`				mapb[xc][yc]+=1.0 - j/(double) li;
			}

			xp = -coords[iter].first * ca0 - coords[iter].second * sa0;
			yp = -coords[iter].first * sa0 + coords[iter].second * ca0;
			zp = x*ca1 + y * sa1;
			wp = x*sa1 - y * ca1;

			cxp = xp * ca2 - zp * sa2;
			czp = xp * sa2 + zp * ca2;
			cyp = yp * ca3 - wp * sa3;
			cwp = yp * sa3 + wp * ca3;

			xp = cxp * ca4 - cwp * sa4;
			wp = cxp * sa4 + cwp * ca4;
			yp = cyp * ca5 - czp * sa5;
			zp = cyp * sa5 + czp * ca5;

			xc = (WIDTH - HEIGHT)/2 + (1.5*yp+2.5)*HEIGHT/4.0;
			yc = (1.5*xp+2)*HEIGHT/4.0;

			if(xc>=0 && yc>=0 && xc < WIDTH && yc < HEIGHT) {
				mapr[xc][yc]+=j/(double) li;
				mapg[xc][yc]+=1 - j/(double) li;
//				mapg[xc][yc]++;
				mapb[xc][yc]++;
			}
		}
	}
}

double min(double a, double b) {
  if (a < b) {
    return a;
  }
  else {
    return b;
  }
}

SDL_Surface* s = NULL;
int mval[3] = { 0, 0, 0 };
void paint() {
	int x, y;
	if (mval[0] == 0) {
		for(x = 0; x < WIDTH; x++) {
			for(y = 0; y < HEIGHT; y++) {
				if(mapr[x][y] > mval[0]) mval[0] = mapr[x][y];
				if(mapg[x][y] > mval[1]) mval[1] = mapg[x][y];
				if(mapb[x][y] > mval[2]) mval[2] = mapb[x][y];
			}
		}
	}


	for(x = 0; x < WIDTH; x++) {
		for(y = 0; y < HEIGHT; y++) {

			SDL_Rect r;
			r.x = x;
			r.y = y;
			r.w = 1;
			r.h = 1;
			int R = 255.0 * min(1.0, mapr[x][y] / (double)mval[0]);
			int G = 255.0 * min(1.0, mapg[x][y] / (double)mval[1]);
			int B = 255.0 * min(1.0, mapb[x][y] / (double)mval[2]);
			SDL_FillRect(s, &r, SDL_MapRGB(s->format, R, G, B));
			mapr[x][y] = mapg[x][y] = mapb[x][y] = 0;
		}
	}
	SDL_Flip(s);

};

void mbrotsweep() {
	int X, Y;
	for(X = 0; X < WIDTH; X++) {
		for(Y = 0; Y < HEIGHT; Y++) {
			mapr[X][Y] = 0;
			mapg[X][Y] = 0;
			mapb[X][Y] = 0;
		}
	}

	render();
	paint();

}

void save() {
	static int i = 0;
	char filename[16];
	sprintf(filename, "out%.4d.bmp.tmp", i);
	SDL_WM_SetCaption(filename, NULL);
	SDL_SaveBMP(s, filename);
	char filename2[16];
	sprintf(filename2, "out%.4d.bmp", i++);
	rename(filename, filename2);

}


void exportFile() {
	ofstream of("out.dat", ios::out | ios::binary | ios::trunc);
	printf("%d\n", lens.size());
	int sz = lens.size();
	of.write(reinterpret_cast<char *>(&sz), sizeof(sz));
//	of << lens.size();
	for (int i : lens) {
		of.write(reinterpret_cast<char *>(&i), sizeof(i));
	}

	printf("%d\n", origins.size());
	sz = origins.size();
	of.write(reinterpret_cast<char *>(&sz), sizeof(sz));
	for (pair<double,double> p : origins) {
		of.write(reinterpret_cast<char *>(&p.first), sizeof(p.first));
		of.write(reinterpret_cast<char *>(&p.second), sizeof(p.second));
	}
	printf("%d\n", coords.size());
	sz = coords.size();
	of.write(reinterpret_cast<char *>(&sz), sizeof(sz));
	for (pair<double,double> p : coords) {
		of.write(reinterpret_cast<char *>(&p.first), sizeof(p.first));
		of.write(reinterpret_cast<char *>(&p.second), sizeof(p.second));
	}

}
void importFile() {
	ifstream ifs("out.dat", ios::in | ios::binary);
	int i; double x; double y;
	ifs.read(reinterpret_cast<char *>(&i), sizeof(i));
	printf("%d\n", i);
	fflush(NULL);
	lens.reserve(i);
	for (int j = 0; j < i; j++) {
		int k;
		ifs.read(reinterpret_cast<char *>(&k), sizeof(k));
		lens.push_back(k);
	}
	ifs.read(reinterpret_cast<char *>(&i), sizeof(i));
	printf("%d\n", i);
	fflush(NULL);
	origins.reserve(i);
	for (int j = 0; j < i; j++) {
		ifs.read(reinterpret_cast<char *>(&x), sizeof(x));
		ifs.read(reinterpret_cast<char *>(&y), sizeof(y));
		origins.push_back({x,y});
	}
	ifs.read(reinterpret_cast<char *>(&i), sizeof(i));
	printf("%d\n", i);
	fflush(NULL);
	coords.reserve(i);
	for (int j = 0; j < i; j++) {
		ifs.read(reinterpret_cast<char *>(&x), sizeof(x));
		ifs.read(reinterpret_cast<char *>(&y), sizeof(y));
		coords.push_back({x,y});
	}

}

int main(int argc, char* argv[]) {
	SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER);
	s = SDL_SetVideoMode(WIDTH, HEIGHT, 16, SDL_SWSURFACE);

	double x, y;



/*	for(x = 0; x < WIDTH; x+=SUBSTEP) {
		printf("%2.2f%% - %d - %2.2f Mb \n", (100.0*x)/WIDTH, coords.size(), 8 * coords.size() / 1024 / 1024.);
		for(y = 0; y < (HEIGHT)/2; y+=SUBSTEP) {
			mapbrot((double)4*(x-WIDTH/2) / (double) WIDTH, (double)4*(y-HEIGHT/2) / (double) HEIGHT, 0, 0);
		}
	}*/
//	exportFile();
	importFile();

	const double step = M_PI / 40000.0;
	double t = M_PI/3.0;
	for(t = 0; t < 2*M_PI; t+=step) {
		angle[2]=M_PI+M_PI*cos(t);
		angle[3]=M_PI+M_PI*cos(2*t);
		angle[4]=M_PI+M_PI*cos(3*t);
		angle[5]=M_PI+M_PI*cos(5*t);
		mbrotsweep();
		save();
	}

	/*
	for(angle[2] = 0; angle[2] < 2*M_PI; angle[2]+=step) {
		frame(angle);
		save();
	}
	angle[2] = 0;
	for(angle[3] = 0; angle[3] < 2*M_PI; angle[3]+=step) {
		frame(angle);
		save();
	}
	angle[3] = 0;
	for(angle[4] = 0; angle[4] < 2*M_PI; angle[4]+=step) {
		frame(angle);
		save();
	}
	angle[4] = 0;
	for(angle[5] = 0; angle[5] < 2*M_PI; angle[5]+=step) {
		frame(angle);
		save();
	}
	angle[5] = 0;

	for(angle[2] = 0; angle[2] < M_PI/2; angle[2]+=step) {
		frame(angle);
		save();
	}
	angle[2] = M_PI/2;
	for(angle[3] = 0; angle[3] < M_PI; angle[3]+=step) {
		frame(angle);
		save();
	}
	angle[3] = M_PI;
	for(angle[5] = 0; angle[5] < M_PI; angle[5]+=step) {
		frame(angle);
		save();
	}
	angle[5] = M_PI;
	for(angle[2] = M_PI/2; angle[2] < M_PI; angle[2]+=step) {
		frame(angle);
		save();
	}
	angle[2] = M_PI;
	for(angle[3] = M_PI; angle[3] < 2*M_PI; angle[3]+=step) {
		frame(angle);
		save();
	}
	angle[3] = M_PI*2;
	for(angle[5] = M_PI; angle[5] < M_PI*2; angle[5]+=step) {
		frame(angle);
		save();
	}*/
	printf("\nALL DONE\n");

	for(;;) SDL_Flip(s);
}
