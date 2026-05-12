"use client";

import React, { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { 
  LayoutDashboard, 
  Users, 
  UserSquare2, 
  BookOpen, 
  BookMarked, 
  QrCode, 
  Bell, 
  LogOut, 
  Menu, 
  PanelLeftClose,
  ChevronRight,
  GraduationCap
} from "lucide-react";
import { cn } from "@/lib/utils";

interface SidebarItem {
  title: string;
  href: string;
  icon: React.ElementType;
}

const menuItems: SidebarItem[] = [
  { title: "Dashboard", href: "/admin", icon: LayoutDashboard },
  { title: "Teachers", href: "/admin/teachers", icon: GraduationCap },
  { title: "Students", href: "/admin/students", icon: Users },
  { title: "Courses", href: "/admin/courses", icon: BookOpen },
  { title: "Subjects", href: "/admin/subjects", icon: BookMarked },
  { title: "Attendance", href: "/admin/attendance", icon: QrCode },
  { title: "Notifications", href: "/admin/notifications", icon: Bell },
];

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const pathname = usePathname();

  return (
    <div className="flex min-h-screen bg-[#F8FAFC]">
      {/* Sidebar */}
      <aside
        className={cn(
          "fixed top-0 left-0 z-40 h-screen transition-all duration-300 ease-in-out border-r border-slate-200 bg-white",
          isCollapsed ? "w-[70px]" : "w-[240px]"
        )}
      >
        <div className="flex flex-col h-full">
          {/* Header */}
          <div className="flex items-center h-[72px] px-4 overflow-hidden border-b border-slate-100">
            <div className="flex items-center min-w-max gap-3">
              <div className="flex items-center justify-center w-10 h-10 rounded-xl bg-gradient-to-br from-indigo-500 to-blue-600 shadow-md shadow-indigo-200">
                <GraduationCap className="w-5 h-5 text-white" />
              </div>
              {!isCollapsed && (
                <div className="flex flex-col">
                  <span className="text-[15px] font-bold text-slate-800 leading-tight">AdminPanel</span>
                  <span className="text-[11px] font-medium text-slate-400">College ERP</span>
                </div>
              )}
            </div>
            {!isCollapsed && (
              <button 
                onClick={() => setIsCollapsed(true)}
                className="ml-auto p-1.5 rounded-lg hover:bg-slate-50 text-slate-400 transition-colors"
              >
                <PanelLeftClose className="w-4 h-4" />
              </button>
            )}
          </div>

          {/* Navigation */}
          <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
            {isCollapsed && (
              <button 
                onClick={() => setIsCollapsed(false)}
                className="w-full flex justify-center py-3 mb-4 rounded-xl hover:bg-slate-50 text-slate-500"
              >
                <Menu className="w-5 h-5" />
              </button>
            )}
            
            {menuItems.map((item) => {
              const isActive = pathname === item.href || (item.href !== "/admin" && pathname?.startsWith(item.href));
              return (
                <Link
                  key={item.title}
                  href={item.href}
                  className={cn(
                    "flex items-center h-11 px-3 rounded-xl transition-all duration-200 group relative",
                    isActive 
                      ? "bg-indigo-50 text-indigo-600 shadow-sm shadow-indigo-100/50" 
                      : "text-slate-500 hover:bg-slate-50 hover:text-slate-700"
                  )}
                >
                  <item.icon className={cn(
                    "w-5 h-5 min-w-[20px]",
                    isActive ? "text-indigo-600" : "text-slate-400 group-hover:text-slate-600"
                  )} />
                  {!isCollapsed && (
                    <>
                      <span className="ml-3 text-[14px] font-medium truncate">{item.title}</span>
                      {isActive && (
                        <div className="ml-auto w-1.5 h-1.5 rounded-full bg-indigo-500" />
                      )}
                    </>
                  )}
                  {isCollapsed && (
                    <div className="absolute left-14 px-2 py-1 rounded bg-slate-800 text-white text-xs opacity-0 group-hover:opacity-100 pointer-events-none whitespace-nowrap transition-opacity z-50">
                      {item.title}
                    </div>
                  )}
                </Link>
              );
            })}
          </nav>

          {/* Footer */}
          <div className="p-4 border-t border-slate-100">
            <div className={cn(
              "flex items-center",
              isCollapsed ? "justify-center" : "gap-3"
            )}>
              <div className="relative">
                <div className="w-9 h-9 rounded-full bg-purple-100 flex items-center justify-center text-purple-600 font-bold text-sm">
                  A
                </div>
                <div className="absolute bottom-0 right-0 w-2.5 h-2.5 bg-green-500 border-2 border-white rounded-full" />
              </div>
              {!isCollapsed && (
                <div className="flex flex-col min-w-0 flex-1">
                  <span className="text-[13px] font-semibold text-slate-800 truncate">Admin User</span>
                  <span className="text-[11px] text-slate-400 truncate">Super Admin</span>
                </div>
              )}
              {!isCollapsed && (
                <button className="p-1.5 rounded-lg hover:bg-slate-50 text-slate-400">
                  <LogOut className="w-4 h-4" />
                </button>
              )}
            </div>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main 
        className={cn(
          "flex-1 transition-all duration-300 ease-in-out",
          isCollapsed ? "pl-[70px]" : "pl-[240px]"
        )}
      >
        {children}
      </main>
    </div>
  );
}
