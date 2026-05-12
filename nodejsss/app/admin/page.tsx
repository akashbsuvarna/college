"use client";

import React from "react";
import { 
  Search, 
  Users, 
  GraduationCap, 
  BookOpen, 
  BookMarked, 
  TrendingUp, 
  Clock, 
  CheckCircle2, 
  XCircle,
  MoreVertical,
  CalendarDays
} from "lucide-react";
import { cn } from "@/lib/utils";

const stats = [
  { 
    title: "Total Students", 
    value: "256", 
    trend: "+12 this month", 
    trendUp: true, 
    icon: Users, 
    color: "bg-indigo-100 text-indigo-600" 
  },
  { 
    title: "Total Teachers", 
    value: "18", 
    trend: "+2 this month", 
    trendUp: true, 
    icon: GraduationCap, 
    color: "bg-blue-100 text-blue-600" 
  },
  { 
    title: "Total Courses", 
    value: "32", 
    trend: "+3 this month", 
    trendUp: true, 
    icon: BookOpen, 
    color: "bg-orange-100 text-orange-600" 
  },
  { 
    title: "Total Subjects", 
    value: "68", 
    trend: "+5 this month", 
    trendUp: true, 
    icon: BookMarked, 
    color: "bg-purple-100 text-purple-600" 
  },
];

const activities = [
  { id: 1, title: "New student registration", subtitle: "mohan requested for admission", time: "10 min ago", icon: Users, color: "bg-indigo-50 text-indigo-500" },
  { id: 2, title: "Attendance marked", subtitle: "BCA Sem 3 attendance marked", time: "1 hour ago", icon: CheckCircle2, color: "bg-orange-50 text-orange-500" },
  { id: 3, title: "New course added", subtitle: "Data Structures course added", time: "3 hours ago", icon: BookOpen, color: "bg-blue-50 text-blue-500" },
  { id: 4, title: "Teacher joined", subtitle: "Prof. Sharma joined Mechanical Dept.", time: "5 hours ago", icon: GraduationCap, color: "bg-purple-50 text-purple-500" },
];

const pendingRequests = [
  { id: 1, name: "mohan", details: "BCA • Sem 3", email: "abcd@gmail.com", phone: "987654321", avatar: "M" },
];

export default function AdminDashboard() {
  return (
    <div className="p-8">
      {/* Top Bar */}
      <div className="flex items-center justify-between mb-8">
        <h1 className="text-2xl font-bold text-slate-800">Dashboard</h1>
        
        <div className="flex items-center gap-4">
          <div className="relative group">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 group-focus-within:text-indigo-500 transition-colors" />
            <input 
              type="text" 
              placeholder="Search..." 
              className="pl-10 pr-4 py-2 bg-white border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all w-64"
            />
          </div>
          <div className="w-10 h-10 rounded-full bg-indigo-50 flex items-center justify-center text-indigo-600 font-bold text-sm">
            A
          </div>
        </div>
      </div>

      {/* Welcome Section */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h2 className="text-xl font-bold text-slate-800">Welcome back, Admin User!</h2>
          <p className="text-sm text-slate-500">Here's what's happening in your college today.</p>
        </div>
        <div className="flex items-center gap-3 px-4 py-2 bg-white border border-slate-200 rounded-xl text-sm font-medium text-slate-600 shadow-sm">
          <CalendarDays className="w-4 h-4 text-slate-400" />
          <span>May 26, 2025 • Monday</span>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {stats.map((stat) => (
          <div key={stat.title} className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm hover:shadow-md transition-shadow">
            <div className="flex items-center justify-between mb-4">
              <div className={cn("p-3 rounded-xl", stat.color)}>
                <stat.icon className="w-6 h-6" />
              </div>
              <button className="text-slate-400 hover:text-slate-600 transition-colors">
                <MoreVertical className="w-4 h-4" />
              </button>
            </div>
            <div className="flex flex-col">
              <span className="text-sm font-medium text-slate-500">{stat.title}</span>
              <span className="text-2xl font-bold text-slate-800 my-1">{stat.value}</span>
              <div className="flex items-center gap-1.5 mt-1">
                <div className={cn("flex items-center", stat.trendUp ? "text-green-500" : "text-red-500")}>
                  <TrendingUp className="w-3.5 h-3.5" />
                </div>
                <span className={cn("text-[13px] font-medium", stat.trendUp ? "text-green-600" : "text-red-600")}>
                  {stat.trend}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Charts & Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        {/* Attendance Overview (Placeholder) */}
        <div className="lg:col-span-2 bg-white p-6 rounded-2xl border border-slate-100 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <h3 className="font-bold text-slate-800">Attendance Overview</h3>
            <select className="bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 text-xs font-semibold text-slate-600 focus:outline-none focus:ring-2 focus:ring-indigo-500/20">
              <option>This Week</option>
              <option>Last Week</option>
            </select>
          </div>
          <div className="h-64 flex items-center justify-center border-2 border-dashed border-slate-100 rounded-2xl bg-slate-50/50">
            <div className="flex flex-col items-center text-slate-400">
              <TrendingUp className="w-12 h-12 mb-2 opacity-20" />
              <span className="text-sm font-medium">Chart visualization would go here</span>
            </div>
          </div>
          <div className="grid grid-cols-3 gap-4 mt-6 pt-6 border-t border-slate-50">
            <div className="p-4 rounded-xl bg-indigo-50/30">
              <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block mb-1">Avg. Attendance</span>
              <span className="text-lg font-bold text-slate-800">82%</span>
              <span className="text-[11px] text-slate-500 block">This Week</span>
            </div>
            <div className="p-4 rounded-xl bg-green-50/30">
              <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block mb-1">Present</span>
              <span className="text-lg font-bold text-slate-800">210</span>
              <span className="text-[11px] text-slate-500 block">Students</span>
            </div>
            <div className="p-4 rounded-xl bg-red-50/30">
              <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block mb-1">Absent</span>
              <span className="text-lg font-bold text-slate-800">46</span>
              <span className="text-[11px] text-slate-500 block">Students</span>
            </div>
          </div>
        </div>

        {/* Recent Activities */}
        <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm flex flex-col">
          <h3 className="font-bold text-slate-800 mb-6">Recent Activities</h3>
          <div className="flex-1 space-y-6">
            {activities.map((activity) => (
              <div key={activity.id} className="flex gap-4 group">
                <div className={cn("w-10 h-10 min-w-[40px] rounded-xl flex items-center justify-center transition-transform group-hover:scale-110", activity.color)}>
                  <activity.icon className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between gap-2">
                    <h4 className="text-[13px] font-bold text-slate-800 truncate">{activity.title}</h4>
                    <span className="text-[11px] font-medium text-slate-400 whitespace-nowrap">{activity.time}</span>
                  </div>
                  <p className="text-[12px] text-slate-500 truncate">{activity.subtitle}</p>
                </div>
              </div>
            ))}
          </div>
          <button className="mt-8 w-full py-2.5 bg-slate-50 hover:bg-slate-100 text-slate-600 text-sm font-bold rounded-xl transition-colors">
            View All Activities
          </button>
        </div>
      </div>

      {/* Bottom Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Students Overview (Donut Chart Placeholder) */}
        <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm">
          <h3 className="font-bold text-slate-800 mb-6">Students Overview</h3>
          <div className="flex flex-col sm:flex-row items-center gap-8">
            <div className="relative w-40 h-40 flex items-center justify-center border-[12px] border-indigo-500 border-t-orange-400 border-r-slate-300 rounded-full">
              <div className="flex flex-col items-center">
                <span className="text-2xl font-bold text-slate-800">256</span>
                <span className="text-[11px] text-slate-400 font-bold uppercase tracking-wider">Total</span>
              </div>
            </div>
            <div className="flex-1 space-y-4 w-full sm:w-auto">
              {[
                { label: "Active Students", value: "200", percent: "78%", color: "bg-indigo-500" },
                { label: "Pending Requests", value: "28", percent: "11%", color: "bg-orange-400" },
                { label: "Inactive Students", value: "28", percent: "11%", color: "bg-slate-300" },
              ].map((item) => (
                <div key={item.label} className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className={cn("w-3 h-3 rounded-full", item.color)} />
                    <span className="text-sm font-medium text-slate-600">{item.label}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-bold text-slate-800">{item.value}</span>
                    <span className="text-[12px] text-slate-400 font-medium">({item.percent})</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Pending Requests */}
        <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm flex flex-col">
          <div className="flex items-center justify-between mb-6">
            <h3 className="font-bold text-slate-800">Pending Requests</h3>
            <button className="text-[12px] font-bold text-indigo-600 hover:text-indigo-700">View All</button>
          </div>
          <div className="flex-1 space-y-4">
            {pendingRequests.map((req) => (
              <div key={req.id} className="p-4 bg-slate-50/50 rounded-2xl border border-slate-100 flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-indigo-600 flex items-center justify-center text-white font-bold text-lg">
                  {req.avatar}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
                    <div>
                      <h4 className="font-bold text-slate-800">{req.name}</h4>
                      <p className="text-[12px] text-slate-500 font-medium">{req.details}</p>
                    </div>
                    <div className="hidden sm:block text-right">
                      <p className="text-[12px] text-slate-500">{req.email}</p>
                      <p className="text-[12px] text-slate-500">{req.phone}</p>
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <button className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white shadow-sm shadow-green-100 hover:bg-green-600 transition-colors">
                    <CheckCircle2 className="w-4 h-4" />
                  </button>
                  <button className="w-8 h-8 rounded-full bg-red-500 flex items-center justify-center text-white shadow-sm shadow-red-100 hover:bg-red-600 transition-colors">
                    <XCircle className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
          <button className="mt-6 w-full py-2.5 bg-indigo-50/50 hover:bg-indigo-50 text-indigo-600 text-sm font-bold rounded-xl transition-colors">
            View All Requests
          </button>
        </div>
      </div>
    </div>
  );
}
