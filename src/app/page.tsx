'use client';

import StepOne, { StepOneParams } from "@/components/step-1";
import { Item } from "@/models/item.models";
import { useState, useEffect } from "react";
import { Steps } from 'antd';


export default function Home() {

  const [currentStep, setCurrentStep] = useState(0);

  const [items, setItems] = useState<Item[]>([]);

  const steps = [
    {
      title: 'Add Items',
    },  
    {
      title: 'Add People',
    },
    {
      title: 'Assign People & Items',
    },
    {
      title: 'Review & Split',
    },
  ];

  useEffect(() => {
    setCurrentStep(0);
    setItems([ new Item({}) ]);
  }, [currentStep]);

  const StepOneParams: StepOneParams = {
    items,
    setItems,
  };

  return (
    <main className="max-w-[1100px] min-w-[50vw]  w-fit h-screen m-auto py-10">
      <h1 className="text-center text-main">Let's Split the Bill</h1>

      <section className="my-20">
        <Steps
          size="small"
          current={currentStep}
          labelPlacement="vertical" 
          items={steps}
        />


        <div className="py-20">
          <StepOne params={ StepOneParams } />
        </div>
      </section>
    </main>
  );
}
