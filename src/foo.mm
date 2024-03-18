#include <iostream>

#include <GLFW/glfw3.h>
#define GLFW_EXPOSE_NATIVE_COCOA
#include <GLFW/glfw3native.h>
#include <imgui.h>
#include <backends/imgui_impl_osx.h>
#include <backends/imgui_impl_metal.h>
#include <Metal/Metal.h>
#include <QuartzCore/CAMetalLayer.h>

int main() {
    if (!glfwInit()) {
        std::cout << "Failed to init GLFW\n";
        return 1;
    }
    auto* W = glfwCreateWindow(1000, 800, "My Window", nullptr, nullptr);
    if (!W) {
        std::cout << "Failed to create window\n";
        return 1;
    }
    int width = 0, height = 0;
    glfwGetWindowSize(W, &width, &height);
    ImGui::CreateContext();
    NSWindow* NSW = glfwGetCocoaWindow(W);
    ImGui_ImplOSX_Init(NSW.contentView);
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    ImGui_ImplMetal_Init(device);
    CAMetalLayer* layer = [[CAMetalLayer alloc] init];
    layer.device = device;
    layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    layer.drawableSize = CGSize{ 2.0 * width, 2.0 * height };
    NSW.contentView.wantsLayer = true;
    [NSW.contentView setLayer:layer];
    id commandQueue = [device newCommandQueue];
    ImGui_ImplMetal_CreateFontsTexture(device);
    while (!glfwWindowShouldClose(W)) {
        ImGuiIO& io = ImGui::GetIO();
        io.DisplaySize = ImVec2(width, height);
        ImGui_ImplOSX_NewFrame(NSW.contentView);
        ImGui::NewFrame();
        
        // User code
        ImGui::ShowDemoWindow();
        
        id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
        MTLRenderPassDescriptor* renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
        MTLRenderPassColorAttachmentDescriptor* caDesc = [[MTLRenderPassColorAttachmentDescriptor alloc] init];
        id<CAMetalDrawable> drawable = layer.nextDrawable;
        caDesc.texture = drawable.texture;
        caDesc.loadAction = MTLLoadActionClear;
        caDesc.storeAction = MTLStoreActionStore;
        [renderPassDescriptor.colorAttachments setObject: caDesc
                                      atIndexedSubscript: 0];
        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        
        // Rendering
        ImGui::Render();
        ImDrawData* drawData = ImGui::GetDrawData();
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 0, 1, 1);
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"Dear ImGui rendering"];
        ImGui_ImplMetal_RenderDrawData(drawData, commandBuffer, renderEncoder);
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];
        // Present
        [commandBuffer presentDrawable: drawable];
        [commandBuffer commit];
        [drawable present];
        
        glfwPollEvents();
    }
    ImGui_ImplMetal_Shutdown();
    ImGui_ImplOSX_Shutdown();
}
