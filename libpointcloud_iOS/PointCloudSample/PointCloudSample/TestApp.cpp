/**
 * Copyright (C) 2012 13th Lab AB
 *
 * See the LICENSE file that came with this example code.
 */ 

#include "TestApp.h"
#include "PointCloud.h"
#include <string>
#include <unistd.h>
#include "path.h"


TestApp::TestApp(int viewport_width, int viewport_height, 
				 int video_width, int video_height, 
				 pointcloud_video_format video_format,
				 const char* resource_path, 
				 const char* documents_path,
				 const char* device,
				 double ui_scale_factor) :
PointCloudApplication(viewport_width, viewport_height,
					  video_width, video_height,
					  video_format,
					  resource_path,
					  documents_path,
					  device,
					  ui_scale_factor)
{
	setup_cuboid();
	
	// Add images to look for (detection will not start until images are activated, though)
	std::string image_target_1_path = resource_path + std::string("image_target_1.model");
    std::string image_target_2_path = resource_path + std::string("image_target_2.model");
    
    pointcloud_add_image_target("image_1", image_target_1_path.c_str(), 0.3, -1);
    pointcloud_add_image_target("image_2", image_target_2_path.c_str(), 0.3, -1);
    	
	// Create the texture used for the UI
//	ui_texture = read_png_texture("ui.png", true);
    //*Saved map
    flag = -1;

}


// Most convoluted way to make a cuboid
void TestApp::setup_cuboid() {
	float corners[8][3];
	float normals[6][3];
	
    double len = 0.1;
    
	for (int i = 0; i < 8; i++) {
		corners[i][0] = -len/2;
		corners[i][1] = 0;
		corners[i][2] = -len/2;
	}
	
	for (int i = 0; i < 6; i++) {
		for (int j = 0; j < 3; j++) {
			normals[i][j] = 0;
		}
	}
	
	normals[0][0] = 1;
	normals[1][2] = 1;
	normals[2][1] = 1;
	normals[3][0] = -1;
	normals[4][2] = -1;
	normals[5][1] = -1;
		
	corners[1][0] += len;
	corners[2][0] += len;
	corners[5][0] += len;
	corners[6][0] += len;
	
	corners[2][2] += len;
	corners[3][2] += len;
	corners[6][2] += len;
	corners[7][2] += len;
	
	corners[4][1] += len*3;
	corners[5][1] += len*3;
	corners[6][1] += len*3;
	corners[7][1] += len*3;
	
	int strip[] = {4,0,5,1,6,2,7,3,4,0,0,1,3,2,2,6,7,5,4};
	int side[] =  {4,4,4,4,0,0,1,1,3,3,5,5,5,5,2,2,2,2,2};
	
	for (int i = 0; i < sizeof(strip)/sizeof(int); i++) {
		int c = strip[i];
		int s = side[i];
		for (int j = 0; j < 3; j++) {
			cuboid_vertices[i][j] = corners[c][j];
			cuboid_normals[i][j] = normals[s][j];
		}
	}
    
    this->selected_button = SLAM;
}


/*
void TestApp::draw_ui() {
	// Draws a basic UI to control the demo app
	pointcloud_state state = pointcloud_get_state();
	double now = current_time();
	bool is_slam = !(state == POINTCLOUD_LOOKING_FOR_IMAGES || state == POINTCLOUD_TRACKING_IMAGES);
	
	int w = context.viewport_width;
	int h = context.viewport_height;
	double scale_factor = w == 320 ? 0.5 : 1.0;
	double text_w = 138*scale_factor;
	double text_h = 112*scale_factor;
	
	double footer_h = 112*scale_factor;
	static double third = 1.0/3.0;
	
	
	
	// Header background
	draw_image(ui_texture, 0, 20, w, 60*scale_factor, 1/512.0, 332/512.0, 25/512.0, (332+60)/512.0);
	
	// Header text
	draw_image(ui_texture, (w-283*scale_factor)/2, 20+((60-36)/2)*scale_factor, 283*scale_factor, 36*scale_factor, 1/512.0, 289/512.0, 283/512.0, (289+36)/512.0);
	

	// Footer
	if (this->selected_button == IMAGE) {
		// Image Recognition button selected
		draw_image(ui_texture, 0,			h-footer_h, w*third, footer_h,   1/512.0, 400/512.0, 47/512.0, 512/512.0);
		draw_image(ui_texture, w*third,		h-footer_h, w*third, footer_h,  49/512.0, 400/512.0, 95/512.0, 512/512.0);
		draw_image(ui_texture, 2*w*third,	h-footer_h, w*third, footer_h,  49/512.0, 400/512.0, 95/512.0, 512/512.0);
	}
	else if (this->selected_button == SLAM){
		// SLAM button selected
		draw_image(ui_texture, 0,			h-footer_h, w*third, footer_h,  49/512.0, 400/512.0, 95/512.0, 512/512.0);
		draw_image(ui_texture, w*third,		h-footer_h, w*third, footer_h,   1/512.0, 400/512.0, 47/512.0, 512/512.0 );
		draw_image(ui_texture, 2*w*third,	h-footer_h, w*third, footer_h,  49/512.0, 400/512.0, 95/512.0, 512/512.0);
	} 
    else if (this->selected_button == SLAM_FROM_IMAGE){
		// SLAM with Image button selected
		draw_image(ui_texture, 0,			h-footer_h, w*third, footer_h,  49/512.0, 400/512.0, 95/512.0, 512/512.0);
		draw_image(ui_texture, w*third,		h-footer_h, w*third, footer_h,  49/512.0, 400/512.0, 95/512.0, 512/512.0);
		draw_image(ui_texture, 2*w*third,	h-footer_h, w*third, footer_h,   1/512.0, 400/512.0, 47/512.0, 512/512.0);
	} 
	
	// Footer text
	draw_image(ui_texture, w/6-text_w/2,	h-text_h, text_w, text_h,  96/512.0, 400/512.0, (96+138)/512.0, 512/512.0);
	draw_image(ui_texture, w/2-text_w/2,	h-text_h, text_w, text_h,  235/512.0, 400/512.0, (235+138)/512.0, 512/512.0);
	draw_image(ui_texture, 5*w/6-text_w/2,	h-text_h, text_w, text_h,  374/512.0, 400/512.0, (374+138)/512.0, 512/512.0);
	
	// Initialization
	if (is_slam) {
		if (state == POINTCLOUD_TRACKING_SLAM_MAP && last_state == POINTCLOUD_INITIALIZING) {
			init_fadeout_time = now;
		}
		
		double init_fadeout_factor = 1-(now - init_fadeout_time)/2.0; // Fade out in 2 seconds
		
		if (this->selected_button == SLAM && ((state != POINTCLOUD_TRACKING_SLAM_MAP && state != POINTCLOUD_RELOCALIZING) || init_fadeout_factor > 0)) {
			int box_x = (w-429*scale_factor)/2;
			int box_y = (h-289*scale_factor)/2;
			
			// Arrow
			int arrowOffset = 0;
			double opacity = 1.0;
			if (state == POINTCLOUD_INITIALIZING) {
				arrowOffset = 59*scale_factor; 
			}
			else if (state == POINTCLOUD_TRACKING_SLAM_MAP) {
				opacity = init_fadeout_factor;
				arrowOffset = 146*scale_factor;
			}

            // Introduction box and arrow
			// Draw init box
			draw_image(ui_texture,box_x, box_y, 429*scale_factor, 289*scale_factor,  1/512.0, 1/512.0, 429/512.0, 289/512.0, opacity);
			
			// Draw arrow
			draw_image(ui_texture, box_x+26*scale_factor, box_y+86*scale_factor+arrowOffset, 30*scale_factor, 28*scale_factor,  45/512.0, 349/512.0, (45+30)/512.0, (349+28)/512.0, opacity);	
			
		}
	}
	else if (state == POINTCLOUD_LOOKING_FOR_IMAGES) {
		// Show Looking for images.. 
		// Draw top of init box
		int box_x = (w-429*scale_factor)/2;
		int box_y = (h-49*scale_factor)/2;
		draw_image(ui_texture,box_x, box_y, 429*scale_factor, 49*scale_factor,  1/512.0, 1/512.0, 20/512.0, 49/512.0);	
		
		// Draw text 268x34
		draw_image(ui_texture, (w-268*scale_factor)/2, (h-34*scale_factor)/2, 268*scale_factor, 34*scale_factor, 113/512.0, 349/512.0, (113+268)/512.0, (349+34)/512.0);
	}
}
*/


// Drawing a 3d box
void TestApp::render_content(double time_since_last_frame) {
	
    pointcloud_state state = pointcloud_get_state();
	
	// Draw the content if we have SLAM or image tracking
	if (state == POINTCLOUD_TRACKING_SLAM_MAP) {
/*
        // Drawing box
        switch_to_box();

        // Set light position
        static const float light_position[4] = {1, 6, 0.5, 1.0f};
        glLightfv(GL_LIGHT0, GL_POSITION, light_position);
        
        // rendered box color
		glColor4f(1,1,0,1);
		
		glDisable(GL_TEXTURE_2D);
		glEnable(GL_COLOR_MATERIAL);
		glShadeModel(GL_FLAT);
		
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_NORMAL_ARRAY);
		
		glVertexPointer(3, GL_FLOAT, 0, (float *)cuboid_vertices);
		glNormalPointer(GL_FLOAT, 0, (float *)cuboid_normals);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 19);
		
		glDisableClientState(GL_NORMAL_ARRAY);
		glDisableClientState(GL_VERTEX_ARRAY);
		
        glShadeModel(GL_SMOOTH);
		glDisable(GL_COLOR_MATERIAL);
		glColor4f(1, 1, 1, 1);
*/
        if (flag == 1) {
            pointcloud_vector_3 pv3;
            pointcloud_vector_2 pv2;
            pointcloud_vector_2 pv2_v;
            
            pv3 = pointcloud_map_to_camera(near_position.x, near_position.y, near_position.z);
            pv2 = pointcloud_camera_to_video(pv3.x, pv3.y, pv3.z);
            pv2_v = pointcloud_video_to_viewport(pv2.x, pv2.y);
            
            pc_x = pv2_v.x;
            pc_y = pv2_v.y;

        }

    }
}


void TestApp::switch_to_box() {
	enable_lighting();
	
	glShadeModel(GL_SMOOTH);
	
	glDisable(GL_BLEND);
	glDisable(GL_TEXTURE_2D);
	
	glEnable(GL_DEPTH_TEST);
	
	// Set up projection matrix
	glMatrixMode(GL_PROJECTION);
	glLoadMatrixf(projection_matrix.data);
    
	// Set up camera matrix
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
    
    glTranslatef(near_position.x, near_position.y, near_position.z);
    
    GLfloat m[16];
    glGetFloatv(GL_MODELVIEW_MATRIX, m);
    glLoadIdentity();
    // C * M
    glLoadMatrixf(camera_matrix.data);
    glMultMatrixf(m);
}


void TestApp::switch_to_messagebox() {
    disable_lighting();
	
	glDisable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0, context.viewport_width, context.viewport_height, 0, -1, 1);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}


bool TestApp::on_touch_started(double x, double y) {
	
	context_width = context.viewport_width;
	context_height = context.viewport_height;

    //*Only use slam
    
//    pointcloud_reset();

    //* Deactivate image recognition
    pointcloud_deactivate_image_target("image_1");
    pointcloud_deactivate_image_target("image_2");

    if (y > context_height-112 && x < context_width/3) {
        pointcloud_reset();
        //* Deactivate image recognition
        pointcloud_deactivate_image_target("image_1");
        pointcloud_deactivate_image_target("image_2");
        
        printf("Start initialization\n");
        pointcloud_start_slam();

        
    } else if (y > context_height-112 && (x >= context_width/3 && x < context_width*2/3)){
        
        printf("Resetting\n");
        pointcloud_reset();
        
    } else if (y > context_height-112 && context_width*2/3 < x && x < context_width*5/6){
               
        //dumpPath();
        //printf("\n%s\n", createFileName("/pc.txt"));
        
        pointcloud_save_current_map(getDocumentPath());
        printf("\n%s\n", getDocumentPath());
        printf("\nMap saved\n");
        
    } else if (y > context_height-112 && context_width*5/6 < x){
        
        pointcloud_reset();
        pointcloud_load_map(getDocumentPath());
        printf("\n%s\n", getDocumentPath());
        printf("\nMap loaded\n");
    }
    
    if (y < context_height - 112) {
        pointcloud_state state = pointcloud_get_state();
        
        if (state == POINTCLOUD_TRACKING_SLAM_MAP) {
            pointcloud_point_cloud* pc;
            pc = pointcloud_get_points();
            
            //*Point distance variable
            //*current point's distance
            float pd = 0;
            
            //*previous point's distance
            float pd_p = 0;
            int   pd_num = 0;
            
            pointcloud_vector_3 * pv3 = new pointcloud_vector_3[pc->size];
            pointcloud_vector_2 * pv2 = new pointcloud_vector_2[pc->size];
            pointcloud_vector_2 * pv2_v = new pointcloud_vector_2[pc->size];
            
            
            for (int i=0; i<pc->size; i++) {
                //* map to camera, camera to video.
                pv3[i] = pointcloud_map_to_camera(pc->points[i].x, pc->points[i].y, pc->points[i].z);
                pv2[i] = pointcloud_camera_to_video(pv3[i].x, pv3[i].y, pv3[i].z);
                pv2_v[i] = pointcloud_video_to_viewport(pv2[i].x, pv2[i].y);
                
                //*computing the nearest distance.
                pd = sqrt((pv2_v[i].x-(float)x)*(pv2_v[i].x-(float)x) + (pv2_v[i].y-(float)y)*(pv2_v[i].y-(float)y));
                
                //*First frame
                if (pd_p == 0) pd_p = pd;
                else if(pd < pd_p) {
                    pd_p = pd;
                    pd_num = i;
                    
                }
                
            }
            
            near_position.x = pc->points[pd_num].x;
            near_position.y = pc->points[pd_num].y;
            near_position.z = pc->points[pd_num].z;
            
            flag = 1;
            
            //*touched point
            printf("\nNearest distance : %d th, %d Pixel, vX = %d, vY = %d, tX = %d, tY =%d \n", pd_num+1, (int)pd_p, (int)pv2_v[pd_num].x, (int)pv2_v[pd_num].y, (int)x, (int)y);
            pc_x = (int)pv2_v[pd_num].x;
            pc_y = (int)pv2_v[pd_num].y;
            
            
            delete[] pv3;
            delete[] pv2;
            
        }

    }
    
	
	return false;
}
    
    
    

bool TestApp::on_touch_moved(double x, double y) {
	return false;
}

bool TestApp::on_touch_ended(double x, double y) {
	return false;
}

bool TestApp::on_touch_cancelled(double x, double y) {
	return false;
}


